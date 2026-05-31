import { Controller } from "@hotwired/stimulus"


export default class extends Controller {
  static targets = ["textarea", "dropdown", "list"]
  static values = { users: Array }

  connect() {
    this._query = ""
    this._atStart = -1
    this._activeIndex = -1
    this._open = false
  }


  onInput(event) {
    const textarea = event.target
    const cursor = textarea.selectionStart
    const text = textarea.value

    const slice = text.slice(0, cursor)
    const atMatch = slice.match(/@(\w*)$/)

    if (atMatch) {
      this._atStart = slice.lastIndexOf("@")
      this._query = atMatch[1].toLowerCase()
      this._showDropdown(textarea)
    } else {
      this._close()
    }
  }

  onKeydown(event) {
    if (!this._open) return

    const items = this.listTarget.querySelectorAll("[data-mention-item]")
    if (!items.length) return

    switch (event.key) {
      case "ArrowDown":
        event.preventDefault()
        this._activeIndex = (this._activeIndex + 1) % items.length
        this._highlightItem(items)
        break
      case "ArrowUp":
        event.preventDefault()
        this._activeIndex = (this._activeIndex - 1 + items.length) % items.length
        this._highlightItem(items)
        break
      case "Enter":
      case "Tab":
        if (this._activeIndex >= 0 && items[this._activeIndex]) {
          event.preventDefault()
          this._selectItem(items[this._activeIndex].dataset.name)
        }
        break
      case "Escape":
        this._close()
        break
    }
  }

  onBlur() {
    setTimeout(() => this._close(), 150)
  }

  pick(event) {
    const name = event.currentTarget.dataset.name
    this._selectItem(name)
  }


  _showDropdown(textarea) {
    const filtered = this.usersValue.filter(u =>
      u.name.toLowerCase().startsWith(this._query) ||
      u.email.toLowerCase().startsWith(this._query)
    )

    if (!filtered.length) { this._close(); return }

    this._renderItems(filtered)
    this._positionDropdown(textarea)
    this.dropdownTarget.classList.remove("hidden")
    this._open = true
    this._activeIndex = -1
  }

  _renderItems(users) {
    this.listTarget.innerHTML = users.map(u => `
      <li data-mention-item
          data-name="${u.name}"
          data-action="click->mention#pick mousedown->mention#pick"
          class="flex items-center gap-3 px-4 py-2.5 cursor-pointer hover:bg-indigo-50
                 transition-colors duration-75 group">
        <span class="inline-flex items-center justify-center w-7 h-7 rounded-full
                     bg-indigo-100 text-indigo-600 text-xs font-bold uppercase shrink-0
                     group-hover:bg-indigo-200 transition-colors">
          ${u.name.charAt(0)}
        </span>
        <div class="min-w-0">
          <p class="text-sm font-semibold text-slate-800 truncate">${u.name}</p>
          <p class="text-xs text-slate-400 truncate">${u.email}</p>
        </div>
        <span class="ml-auto text-[10px] font-mono text-indigo-400 opacity-0 group-hover:opacity-100 transition-opacity">
          @${u.name}
        </span>
      </li>
    `).join("")
  }

  _highlightItem(items) {
    items.forEach((el, i) => {
      if (i === this._activeIndex) {
        el.classList.add("bg-indigo-50")
        el.scrollIntoView({ block: "nearest" })
      } else {
        el.classList.remove("bg-indigo-50")
      }
    })
  }

  _selectItem(name) {
    const textarea = this.textareaTarget
    const text = textarea.value
    const before = text.slice(0, this._atStart)
    const after = text.slice(textarea.selectionStart)

    textarea.value = `${before}@${name} ${after}`

    const newPos = before.length + name.length + 2  // "@" + name + " "
    textarea.setSelectionRange(newPos, newPos)
    textarea.focus()

    this._close()
  }

  _positionDropdown(textarea) {
    this.dropdownTarget.style.top = `${textarea.offsetTop + textarea.offsetHeight + 4}px`
    this.dropdownTarget.style.left = `${textarea.offsetLeft}px`
    this.dropdownTarget.style.width = `${textarea.offsetWidth}px`
  }

  _close() {
    if (!this._open) return
    this.dropdownTarget.classList.add("hidden")
    this._open = false
    this._activeIndex = -1
    this._query = ""
  }
}
