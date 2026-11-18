import { Controller } from "@hotwired/stimulus"
import hljs from "highlight.js/lib/core"
import bash from "highlight.js/lib/languages/bash"
import css from "highlight.js/lib/languages/css"
import diff from "highlight.js/lib/languages/diff"
import go from "highlight.js/lib/languages/go"
import java from "highlight.js/lib/languages/java"
import javascript from "highlight.js/lib/languages/javascript"
import json from "highlight.js/lib/languages/json"
import php from "highlight.js/lib/languages/php"
import python from "highlight.js/lib/languages/python"
import ruby from "highlight.js/lib/languages/ruby"
import sql from "highlight.js/lib/languages/sql"
import typescript from "highlight.js/lib/languages/typescript"
import xml from "highlight.js/lib/languages/xml"
import yaml from "highlight.js/lib/languages/yaml"

// Only the languages a blog post plausibly shows; each one adds to every page's bundle.
Object.entries({ bash, css, diff, go, java, javascript, json, php, python, ruby, sql, typescript, xml, yaml })
  .forEach(([name, language]) => hljs.registerLanguage(name, language))

// Colours code blocks in a rendered post. The language comes from the block's
// `language-xxx` class (```ruby in the editor) or is detected automatically.
export default class extends Controller {
  connect() {
    this.element.querySelectorAll("pre code").forEach((block) => {
      if (!block.dataset.highlighted) hljs.highlightElement(block)
    })
  }
}
