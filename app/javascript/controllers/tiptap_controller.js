import { Controller } from "@hotwired/stimulus"
import { Editor } from '@tiptap/core'
import StarterKit from '@tiptap/starter-kit'
import { Underline } from '@tiptap/extension-underline'
import { Link } from '@tiptap/extension-link'
import { TextAlign } from '@tiptap/extension-text-align'
import { Table } from '@tiptap/extension-table'
import { TableRow } from '@tiptap/extension-table-row'
import { TableCell } from '@tiptap/extension-table-cell'
import { TableHeader } from '@tiptap/extension-table-header'
import { TextStyle } from '@tiptap/extension-text-style'
import { Color } from '@tiptap/extension-color'
import { Image } from '@tiptap/extension-image'

export default class extends Controller {
  static targets = [
    "editor", "input", 
    "boldBtn", "italicBtn", "strikeBtn", "h2Btn", "h3Btn", "codeBtn",
    "underlineBtn", "linkBtn", 
    "alignLeftBtn", "alignCenterBtn", "bulletListBtn", "orderedListBtn"
  ]

  connect() {
    this.editor = new Editor({
      element: this.editorTarget,
      extensions: [
        StarterKit.configure({
          bulletList: {
            HTMLAttributes: { class: 'list-disc ml-6 space-y-1 my-4' },
          },
          orderedList: {
            HTMLAttributes: { class: 'list-decimal ml-6 space-y-1 my-4' },
          },
          listItem: {
            HTMLAttributes: { class: 'pl-1' },
          }
        }),
        Underline,
        Link.configure({
          openOnClick: false,
          HTMLAttributes: {
            class: 'text-emerald-600 underline hover:text-emerald-800 transition-colors cursor-pointer',
          },
        }),
        TextAlign.configure({
          types: ['heading', 'paragraph'],
        }),
        Table.configure({
          resizable: true,
          HTMLAttributes: {
            class: 'min-w-full border-collapse border border-slate-300 my-4',
          },
        }),
        TableRow,
        TableHeader.configure({
          HTMLAttributes: { class: 'border border-slate-300 bg-slate-100 p-2 font-bold' },
        }),
        TableCell.configure({
          HTMLAttributes: { class: 'border border-slate-300 p-2' },
        }),
        Image.configure({
          inline: false,
          allowBase64: false,
          HTMLAttributes: {
            class: 'max-w-full h-auto rounded-lg my-4', 
          },
        }),
        TextStyle,
        Color
      ],
      content: this.inputTarget.value,
      onUpdate: ({ editor }) => {
        this.inputTarget.value = editor.getHTML()
        this.updateActiveButtons()
      },
      onSelectionUpdate: () => {
        this.updateActiveButtons()
      }
    })

    this.updateActiveButtons()
  }

  disconnect() {
    if (this.editor) this.editor.destroy()
  }

  toggleBold() { this.editor.chain().focus().toggleBold().run() }
  toggleItalic() { this.editor.chain().focus().toggleItalic().run() }
  toggleStrike() { this.editor.chain().focus().toggleStrike().run() }
  toggleH2() { this.editor.chain().focus().toggleHeading({ level: 2 }).run() }
  toggleH3() { this.editor.chain().focus().toggleHeading({ level: 3 }).run() }
  toggleCodeBlock() { this.editor.chain().focus().toggleCodeBlock().run() }
  toggleBulletList() { this.editor.chain().focus().toggleBulletList().run() }
  toggleOrderedList() { this.editor.chain().focus().toggleOrderedList().run() }
  sinkList() { this.editor.chain().focus().sinkListItem('listItem').run() }
  liftList() { this.editor.chain().focus().liftListItem('listItem').run() }
  toggleUnderline() { this.editor.chain().focus().toggleUnderline().run() }
  alignLeft() { this.editor.chain().focus().setTextAlign('left').run() }
  alignCenter() { this.editor.chain().focus().setTextAlign('center').run() }

  setLink() {
    const previousUrl = this.editor.getAttributes('link').href
    const url = window.prompt('Введіть URL посилання:', previousUrl || '')
    
    if (url === null) return 
    if (url === '') {
      this.editor.chain().focus().extendMarkRange('link').unsetLink().run()
      return
    }
    this.editor.chain().focus().extendMarkRange('link').setLink({ href: url }).run()
  }

  insertTable() {
    const rows = window.prompt('How many rows?', '3')
    const cols = window.prompt('How many columns?', '3')

    if (rows && cols) {
      this.editor
        .chain()
        .focus()
        .insertTable({ 
          rows: parseInt(rows, 10), 
          cols: parseInt(cols, 10), 
          withHeaderRow: true 
        })
        .run()
    }
  }

  setColor(event) {
    this.editor.chain().focus().setColor(event.target.value).run()
  }

  updateActiveButtons() {
    if (this.hasBoldBtnTarget) this.toggleButtonClass(this.boldBtnTarget, this.editor.isActive('bold'))
    if (this.hasItalicBtnTarget) this.toggleButtonClass(this.italicBtnTarget, this.editor.isActive('italic'))
    if (this.hasUnderlineBtnTarget) this.toggleButtonClass(this.underlineBtnTarget, this.editor.isActive('underline'))
    if (this.hasStrikeBtnTarget) this.toggleButtonClass(this.strikeBtnTarget, this.editor.isActive('strike'))
    if (this.hasH2BtnTarget) this.toggleButtonClass(this.h2BtnTarget, this.editor.isActive('heading', { level: 2 }))
    if (this.hasH3BtnTarget) this.toggleButtonClass(this.h3BtnTarget, this.editor.isActive('heading', { level: 3 }))
    if (this.hasCodeBtnTarget) this.toggleButtonClass(this.codeBtnTarget, this.editor.isActive('codeBlock'))
    if (this.hasLinkBtnTarget) this.toggleButtonClass(this.linkBtnTarget, this.editor.isActive('link'))
    if (this.hasAlignLeftBtnTarget) this.toggleButtonClass(this.alignLeftBtnTarget, this.editor.isActive({ textAlign: 'left' }))
    if (this.hasAlignCenterBtnTarget) this.toggleButtonClass(this.alignCenterBtnTarget, this.editor.isActive({ textAlign: 'center' }))
    if (this.hasBulletListBtnTarget) this.toggleButtonClass(this.bulletListBtnTarget, this.editor.isActive('bulletList'))
    if (this.hasOrderedListBtnTarget) this.toggleButtonClass(this.orderedListBtnTarget, this.editor.isActive('orderedList'))
  }

  toggleButtonClass(element, isActive) {
    if (!element) return;
    if (isActive) {
      element.classList.add('bg-emerald-100', 'text-emerald-700')
      element.classList.remove('text-slate-700', 'hover:bg-slate-200')
    } else {
      element.classList.remove('bg-emerald-100', 'text-emerald-700')
      element.classList.add('text-slate-700', 'hover:bg-slate-200')
    }
  }

  insertImage() {
    const input = document.createElement("input")
    input.type = "file"
    input.accept = "image/*"
    input.click()

    input.onchange = async () => {
      const file = input.files[0]
      if (!file) return

      const formData = new FormData()
      formData.append("image", file)

      const response = await fetch("/uploads", {
        method: "POST",
        headers: {
          "X-CSRF-Token": document.querySelector('meta[name="csrf-token"]').content
        },
        body: formData
      })

      const data = await response.json()

      this.editor
        .chain()
        .focus()
        .setImage({ src: data.url })
        .run()
    }
  }
}
