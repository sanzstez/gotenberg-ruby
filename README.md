This package is a Ruby client for [Gotenberg](https://gotenberg.dev), a developer-friendly API to interact with powerful 
tools like Chromium and LibreOffice for converting numerous document formats (HTML, Markdown, Word, Excel, etc.) into 
PDF files, and more!

## Requirement

This packages requires [Gotenberg](https://gotenberg.dev), a Docker-powered stateless API for PDF files:

* 🔥 [Live Demo](https://gotenberg.dev/docs/get-started/live-demo)
* [Docker](https://gotenberg.dev/docs/get-started/docker)
* [Docker Compose](https://gotenberg.dev/docs/get-started/docker-compose)
* [Kubernetes](https://gotenberg.dev/docs/get-started/kubernetes)
* [Cloud Run](https://gotenberg.dev/docs/get-started/cloud-run)

## Installation

```ruby
gem "gotenberg-ruby"
```

## Usage

* [Send a request to the API](#send-a-request-to-the-api)
* [Chromium](#chromium)
* [LibreOffice](#libreOffice)
* [PDF Engines](#pdf-engines)
* [Webhook](#webhook)
* [Exiftools](#exiftools)

### Run Gotenberg

Run microservice with docker-compose:

```
version: "3"

services:
  gotenberg:
    image: gotenberg/gotenberg:8
    command:
      - gotenberg
      - --chromium-allow-file-access-from-files=true
    restart: always
    ports:
      - 3000:3000
```

The `--chromium-allow-file-access-from-files=true` flag is required when converting HTML documents that use Vite
CSS, ES modules, module preload imports, fonts, or images uploaded as multipart assets. Gotenberg opens these local
assets through `file://` URLs, so Chromium must be allowed to load files from other local files.

### Send a request to the API

After having created the HTTP request (see below), you have two options:

1. Get the response from the API and handle it according to your need.
2. Save the resulting file to a given directory.

> In the following examples, we assume the Gotenberg API is available at http://localhost:3000.

### Chromium

The [Chromium module](https://gotenberg.dev/docs/routes#convert-with-chromium) interacts with the Chromium browser to convert HTML documents to PDF.

#### Convert a target URL to PDF

See https://gotenberg.dev/docs/routes#url-into-pdf-route.

Converting a target URL to PDF is as simple as:

```ruby
document = Gotenberg::Chromium.call(ENV['GOTENBERG_URL']) do |doc|
  doc.url 'https://my.url'
end
```

#### Usage:

```ruby
# generate pdf output binary data or raise method exception
pdf = document.to_binary

# safe check if pdf generate is success
success = document.success?

# fetch exception data
error_message = document.exception.message

# save PDF file
File.open('filename.pdf', 'wb') do |file|
  file << document.to_binary
end
```

Pass additional headers for faraday client instance (Authorization, User-Agent, etc.):

```ruby
document = Gotenberg::Chromium.call(ENV['GOTENBERG_URL'], headers: { 'Authorization': 'Bearer token123' }) do |doc|
  doc.url 'https://my.url'
end
```

Available exceptions:

```ruby
# raise while PDF transform failed
Gotenberg::TransformError

# raise while change PDF metadata failed
Gotenberg::ModifyMetadataError

# raise while loading asset source failed
Gotenberg::RemoteSourceError
```

You may inject `<link>` and `<script>` HTML elements thanks to the `extra_link_tags` and `extra_script_tags` arguments:

```ruby
document = Gotenberg::Chromium.call(ENV['GOTENBERG_URL']) do |doc|
  doc.url 'https://my.url', ['https://my.css'], ['https://my.js']
end
```

Please note that Gotenberg will add the `<link>` and `<script>` elements based on the order of the arguments.

#### Rails integrations

For rails apps gem provide few helpful helpers for easier access to assets inside your rails app:

```ruby
# read from assets pipeline or webpacker
gotenberg_image_tag 'logo.svg'

# read from absolute file path (use with carefully for security reasons)
gotenberg_image_tag 'app/assets/images/logo.svg', absolute_path: true

# also you can encode you source as base64 data resource (useful for header and footer)
gotenberg_image_tag 'app/assets/images/logo.svg', absolute_path: true, inline: true

# same methods available for js
gotenberg_javascript_tag 'application.js', inline: true

# ... and css. 
gotenberg_stylesheet_tag 'application.css', inline: true
```

⚠️ Gem also supported extracting CSS nested resources defined with url() in experimentally mode.

```ruby
# skip nested resources auto extracting
gotenberg_stylesheet_tag 'application.css', inline: true, skip_analyze: true
```

Applications using `vite_rails` can load assets from the Vite manifest with dedicated helpers:

```erb
<%= gotenberg_vite_image_tag 'images/logo.svg' %>
<%= gotenberg_vite_stylesheet_tag 'entrypoints/pdf.scss' %>
<%= gotenberg_vite_javascript_tag 'entrypoints/pdf.js' %>
```

Each source must be present in the Vite manifest. These helpers only support local manifest assets and do not accept
options such as `inline`, `absolute_path`, or `base_path`. Continue to use the regular Gotenberg helpers for external
URLs and other options.

##### Development Vite PDF build

In development and test environments, Gotenberg needs production-style files instead of URLs from the Vite dev
server. Add a dedicated watch command to `package.json`:

```json
{
  "scripts": {
    "vite:pdf:dev": "vite build --config vite.pdf.config.ts --mode development --watch"
  }
}
```

Run it alongside the Rails application:

```bash
npm run vite:pdf:dev
```

A minimal `vite.pdf.config.ts` for JavaScript and stylesheet PDF entrypoints looks like this:

```ts
import { defineConfig } from 'vite'
import { resolve } from 'node:path'

const root = resolve(__dirname, 'app/javascript')
const entrypoint = (path: string) => resolve(root, path)

export default defineConfig(({ mode }) => {
  if (mode !== 'development') {
    throw new Error(
      'vite.pdf.config.ts is development-only. Use the main Vite build for production PDF assets.'
    )
  }

  return {
    root,
    build: {
      outDir: resolve(__dirname, 'tmp/vite-pdf'),
      emptyOutDir: true,
      manifest: true,
      cssCodeSplit: true,
      rollupOptions: {
        input: {
          'pdf.js': entrypoint('entrypoints/pdf.js'),
          'pdf.css': entrypoint('entrypoints/pdf.scss'),
        },
      },
    },
  }
})
```

This is a Vite build running in watch mode, not the Vite development server. The output directory must match
`config.vite_output_dir`.

#### Convert an HTML document to PDF

See See https://gotenberg.dev/docs/routes#url-into-pdf-route.

Prepare HTML content with build-in Rails methods:

```ruby
# declare HTML renderer
renderer = ApplicationController.renderer.new(https: true, http_host: 'localhost:3000')

# render HTML string for passing into service
index_html = renderer.render 'pdf/document', layout: 'pdf', locals: {}
```

You may convert an HTML document string with:

```ruby
document = Gotenberg::Chromium.call(ENV['GOTENBERG_URL']) do |doc|
  doc.html index_html
end
```

You may also send additional files, like images, fonts, stylesheets, and so on. The only requirement is that their paths
in the HTML DOM are on the root level.

```ruby
document = Gotenberg::Chromium.call(ENV['GOTENBERG_URL']) do |doc|
  doc.html index_html
  doc.assets '/path/to/my.css', '/path/to/my.js', ['<binary string>', 'my.png']
end
```

#### Change PDF meta with exiftools

If you want to use this feature, you need to install additional package to host system:

```
sudo apt install exiftool
```

 and now you can change PDF metatags using exiftools:

```ruby
document = Gotenberg::Chromium.call(ENV['GOTENBERG_URL']) do |doc|
  doc.html index_html
  doc.meta title: 'Custom PDF title'
end
```

Note: for Rails based apps, you can setup <title>Custom PDF title</title> header in index.html and
it will be automatically added to output PDF.

#### Configuration file (optionally)

```ruby
Gotenberg.configure do |config|
  # activate HTML debug mode
  config.html_debug = false

  # default temporary directory for output
  config.backtrace_dir = Rails.root.join('tmp', 'gotenberg')

  # development/test Vite PDF build output
  config.vite_output_dir = 'tmp/vite-pdf'

  # directory containing Vite source entrypoints
  config.vite_source_code_dir = 'app/javascript'
end
```

The Vite options configure the dedicated PDF build used in development and test. Production uses the standard
ViteRuby manifest and compiled assets from the configured public Vite output directory (by default, `public/vite`).

#### Convert one or more markdown files to PDF

See https://gotenberg.dev/docs/routes#markdown-files-into-pdf-route.

You may convert markdown files with:

```ruby
document = Gotenberg::Chromium.call(ENV['GOTENBERG_URL']) do |doc|
  doc.markdown wrapper_html, '/path/to/file.md'
end
```

Or with raw input:

```ruby
document = Gotenberg::Chromium.call(ENV['GOTENBERG_URL']) do |doc|
  doc.markdown wrapper_html, ['<binary data>', 'file.md']
end
```

The first argument is a `Stream` with HTML content, for instance:

```html
<!doctype html>
<html lang="en">
  <head>
    <meta charset="utf-8">
    <title>My PDF</title>
  </head>
  <body>
    {{ toHTML "file.md" }}
  </body>
</html>
```

Here, there is a Go template function `toHTML`. Gotenberg will use it to convert a markdown file's content to HTML.

Like the HTML conversion, you may also send additional files, like images, fonts, stylesheets, and so on. The only 
requirement is that their paths in the HTML DOM are on the root level.

```ruby
document = Gotenberg::Chromium.call(ENV['GOTENBERG_URL']) do |doc|
  doc.markdown wrapper_html, '/path/to/file.md'
  doc.assets '/path/to/my.css', '/path/to/my.js', '/path/to/my2.md', ['<binary data>', 'file_2.md']
end
```

#### Paper size

You may override the default paper size with:

```ruby
document = Gotenberg::Chromium.call(ENV['GOTENBERG_URL']) do |doc|
  doc.html index_html
  doc.paper_size width, height
end
```

Examples of paper size (width x height, in inches):

* `Letter` - 8.5 x 11 (default)
* `Legal` - 8.5 x 14
* `Tabloid` - 11 x 17
* `Ledger` - 17 x 11
* `A0` - 33.1 x 46.8
* `A1` - 23.4 x 33.1
* `A2` - 16.54 x 23.4
* `A3` - 11.7 x 16.54
* `A4` - 8.27 x 11.7
* `A5` - 5.83 x 8.27
* `A6` - 4.13 x 5.83

#### Margins

You may override the default margins (i.e., `0.39`, in inches):

```ruby
document = Gotenberg::Chromium.call(ENV['GOTENBERG_URL']) do |doc|
  doc.html index_html
  doc.margins top: 1, bottom: 1, left: 0.39, right: 0.39
end
```

#### Prefer CSS page size

You may force page size as defined by CSS:

```ruby
document = Gotenberg::Chromium.call(ENV['GOTENBERG_URL']) do |doc|
  doc.html index_html
  doc.prefer_css_page_size
end
```

#### Print the background graphics

```ruby
document = Gotenberg::Chromium.call(ENV['GOTENBERG_URL']) do |doc|
  doc.html index_html
  doc.print_background
end
```

#### Landscape orientation

You may override the default portrait orientation with:

```ruby
document = Gotenberg::Chromium.call(ENV['GOTENBERG_URL']) do |doc|
  doc.html index_html
  doc.landscape
end
```

#### Scale

You may override the default scale of the page rendering (i.e., `1.0`) with:

```ruby
document = Gotenberg::Chromium.call(ENV['GOTENBERG_URL']) do |doc|
  doc.html index_html
  doc.scale 2
end
```

#### Page ranges

You may set the page ranges to print, e.g., `1-5, 8, 11-13`. Empty means all pages.

```ruby
document = Gotenberg::Chromium.call(ENV['GOTENBERG_URL']) do |doc|
  doc.html index_html
  doc.native_page_ranges '1-2'
end
```

#### Header and footer

You may add a header and/or a footer to each page of the PDF:

```ruby
document = Gotenberg::Chromium.call(ENV['GOTENBERG_URL']) do |doc|
  doc.header header_html
  doc.html index_html
  doc.footer footer_html
  doc.margins top: 1, bottom: 1
end
```

Each of them has to be a complete HTML document:

```html
<html>
<head>
    <style>
    body {
        font-size: 8rem;
        margin: 4rem auto;
    }
    </style>
</head>
<body>
<p><span class="pageNumber"></span> of <span class="totalPages"></span></p>
</body>
</html>
```

The following classes allow you to inject printing values:

* `date` - formatted print date.
* `title` - document title.
* `url` - document location.
* `pageNumber` - current page number.
* `totalPages` - total pages in the document.

⚠️ Make sure that:

1. Margins top and bottom are large enough (i.e., `margins(top: 1, bottom: 1, left: 0.39, right: 0.39)`)
2. The font size is big enough.

⚠️ There are some limitations:

* No JavaScript.
* The CSS properties are independent of the ones from the HTML document.
* The footer CSS properties override the ones from the header;
* Only fonts installed in the Docker image are loaded - see the [Fonts chapter](https://gotenberg.dev/docs/configuration#fonts).
* Images only work using a base64 encoded source - i.e., `data:image/png;base64, iVBORw0K....`
* `background-color` and color `CSS` properties require an additional `-webkit-print-color-adjust: exact` CSS property in order to work.
* Assets are not loaded (i.e., CSS files, scripts, fonts, etc.).

#### Wait delay

When the page relies on JavaScript for rendering, and you don't have access to the page's code, you may want to wait a
certain amount of time (i.e., `1s`, `2ms`, etc.) to make sure Chromium has fully rendered the page you're trying to generate.

```ruby
document = Gotenberg::Chromium.call(ENV['GOTENBERG_URL']) do |doc|
  doc.html index_html
  doc.wait_delay '3s'
end
```

#### Wait for expression

You may also wait until a given JavaScript expression returns true:

```ruby
document = Gotenberg::Chromium.call(ENV['GOTENBERG_URL']) do |doc|
  doc.html index_html
  doc.wait_for_expression "window.status === 'ready'"
end
```

#### User agent

You may override the default `User-Agent` header used by Gotenberg:

```ruby
document = Gotenberg::Chromium.call(ENV['GOTENBERG_URL']) do |doc|
  doc.html index_html
  doc.user_agent("Mozilla/5.0 (Windows NT 6.1; Win64; x64; rv:47.0) Gecko/20100101 Firefox/47.0")
end
```

#### Extra HTTP headers

You may add HTTP headers that Chromium will send when loading the HTML document:

```ruby
document = Gotenberg::Chromium.call(ENV['GOTENBERG_URL']) do |doc|
  doc.url 'https://my.url'
  doc.extra_http_headers({'My-Header-1' => 'My value', 'My-Header-2' => 'My value'})
end
```

#### Client Extra HTTP headers

This method just duplicate way of passing headers into faraday client. Have same purpose:

```ruby
document = Gotenberg::Chromium.call(ENV['GOTENBERG_URL']) do |doc|
  doc.url 'https://my.url'
  doc.client_extra_http_headers({ 'Authorization': 'Bearer token123' })
end
```

#### Fail on console exceptions

You may force Gotenberg to return a `409 Conflict` response if there are exceptions in the Chromium console:

```ruby
document = Gotenberg::Chromium.call(ENV['GOTENBERG_URL']) do |doc|
  doc.url 'https://my.url'
  doc.fail_on_console_exceptions
end
```

#### Emulate media type

Some websites have dedicated CSS rules for print. Using `screen` allows you to force the "standard" CSS rules.
You may also force the `print` media type:

```ruby
document = Gotenberg::Chromium.call(ENV['GOTENBERG_URL']) do |doc|
  doc.url 'https://my.url'
  doc.emulate_media_type 'screen'
end
```

#### PDF Format

See https://gotenberg.dev/docs/routes#pdfa-chromium.

You may set the PDF format of the resulting PDF with:

```ruby
document = Gotenberg::Chromium.call(ENV['GOTENBERG_URL']) do |doc|
  doc.url 'https://my.url'
  doc.pdf_format 'PDF/A-1a'
end
```

### LibreOffice

The [LibreOffice module](https://gotenberg.dev/docs/routes#convert-with-libreoffice) interacts with [LibreOffice](https://www.libreoffice.org/) 
to convert documents to PDF, thanks to [unoconv](https://github.com/unoconv/unoconv).

#### Convert documents to PDF

See https://gotenberg.dev/docs/routes#office-documents-into-pdfs-route.

Converting a document to PDF is as simple as:

```ruby
document = Gotenberg::Libreoffice.call(ENV['GOTENBERG_URL']) do |doc|
  doc.convert '/path/to/my.docx'
end
```

If you send many documents, Gotenberg will return a ZIP archive with the PDFs:

```ruby
document = Gotenberg::Libreoffice.call(ENV['GOTENBERG_URL']) do |doc|
  doc.convert '/path/to/my.docx', '/path/to/my.xlsx', ['<binary data>', 'some.odt']
end

# will return binary data with zip archive content
File.open('archive.zip', 'wb') do |file|
  file << document.to_binary
end
```

You may also merge them into one unique PDF:

```ruby
document = Gotenberg::Libreoffice.call(ENV['GOTENBERG_URL']) do |doc|
  doc.merge
  doc.convert '/path/to/my.docx', '/path/to/my.xlsx', ['<binary data>', 'some.odt']
end
```

Please note that the merging order is determined by the order of the arguments.

#### Landscape orientation

You may override the default portrait orientation with:

```ruby
document = Gotenberg::Libreoffice.call(ENV['GOTENBERG_URL']) do |doc|
  doc.landscape
  doc.convert '/path/to/my.docx'
end
```

#### Page ranges

You may set the page ranges to print, e.g., `1-4`. Empty means all pages.

```ruby
document = Gotenberg::Libreoffice.call(ENV['GOTENBERG_URL']) do |doc|
  doc.native_page_ranges '1-2'
  doc.convert '/path/to/my.docx'
end
```

⚠️ The page ranges are applied to all files independently.

#### PDF format

See https://gotenberg.dev/docs/routes#pdfa-libreoffice.

You may set the PDF format of the resulting PDF(s) with:

```ruby
document = Gotenberg::Libreoffice.call(ENV['GOTENBERG_URL']) do |doc|
  doc.pdf_format 'PDF/A-1a'
  doc.convert '/path/to/my.docx'
end
```

You may also explicitly tell Gotenberg to use [unoconv](https://github.com/unoconv/unoconv) to convert the resulting PDF(s) to a PDF format:

```ruby
document = Gotenberg::Libreoffice.call(ENV['GOTENBERG_URL']) do |doc|
  doc.native_pdf_format 'PDF/A-1a'
  doc.convert '/path/to/my.docx'
end
```

⚠️ You cannot set both property, otherwise Gotenberg will return `400 Bad Request` response.


### PDF Engines

The [PDF Engines module](https://gotenberg.dev/docs/configuration#pdf-engines) gathers all engines that can manipulate PDF files.

#### Merge PDFs

See https://gotenberg.dev/docs/routes#merge-pdfs-route.

Merging PDFs is as simple as:

```ruby
document = Gotenberg::PdfEngines.call(ENV['GOTENBERG_URL']) do |doc|
  doc.merge '/path/to/my.pdf', '/path/to/my2.pdf', ['<binary data>', 'some.pdf']
end
```

Please note that the merging order is determined by the order of the arguments.

You may also set the PDF format of the resulting PDF(s) with:

```ruby
document = Gotenberg::PdfEngines.call(ENV['GOTENBERG_URL']) do |doc|
  doc.pdf_format 'PDF/A-1a'
  doc.merge '/path/to/my.pdf', '/path/to/my2.pdf', '/path/to/my3.pdf'
end
```

#### Convert to a specific PDF format

See https://gotenberg.dev/docs/routes#convert-into-pdfa--pdfua-route.

You may convert a PDF to a specific PDF format with:

```ruby
document = Gotenberg::PdfEngines.call(ENV['GOTENBERG_URL']) do |doc|
  doc.convert '/path/to/my.pdf', format: 'PDF/A-1a'
end
```

If you send many PDFs, Gotenberg will return a ZIP archive with the PDFs:

```ruby
document = Gotenberg::PdfEngines.call(ENV['GOTENBERG_URL']) do |doc|
  doc.convert '/path/to/my.pdf', '/path/to/my2.pdf', '/path/to/my3.pdf', ['<binary data>', 'some.pdf'], format: 'PDF/A-1a'
end

# will return binary data with zip archive content
File.open('archive.zip', 'wb') do |file|
  file << document.to_binary
end
```

### Webhook

The [Webhook module](https://gotenberg.dev/docs/webhook) is a Gotenberg middleware that sends the API
responses to callbacks.

⚠️ You cannot use the `document.to_binary` method if you're using the webhook feature.

For instance:

```ruby
document = Gotenberg::Chromium.call(ENV['GOTENBERG_URL']) do |doc|
  doc.url 'https://my.url'
  doc.webhook 'https://my.webhook.url', 'https://my.webhook.error.url'
end
```

You may also override the default HTTP method (`POST`) that Gotenberg will use to call the webhooks:

```ruby
document = Gotenberg::Chromium.call(ENV['GOTENBERG_URL']) do |doc|
  doc.url 'https://my.url'
  doc.webhook_method('PATCH')
  doc.webhook_error_method('PUT')
  doc.webhook 'https://my.webhook.url', 'https://my.webhook.error.url'
end
```

You may also tell Gotenberg to add extra HTTP headers that it will send alongside the request to the webhooks:

```ruby
document = Gotenberg::Chromium.call(ENV['GOTENBERG_URL']) do |doc|
  doc.url 'https://my.url'
  doc.webhook_extra_http_headers({'My-Header-1' => 'My value', 'My-Header-2' => 'My value'})
  doc.webhook 'https://my.webhook.url', 'https://my.webhook.error.url'
end
```

### Exiftools

Gem also proxify (expert mode) access to mini_exiftools througth *Gotenberg::Exiftools* class.
You can change PDF metadata manually:

```ruby
binary = Gotenberg::Exiftools.modify(pdf_binary, { title: 'Document 1' })

# save PDF file
File.open('filename.pdf', 'wb') do |file|
  file << binary
end
```

⚠️ Class is just wrapper around *MiniExiftool* class, so you need handle exceptions manually/carefully in begin/rescue block.
