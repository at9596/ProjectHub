import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="notifications"
// Turbo handles the ActionCable subscription via turbo_stream_from in the navbar.
// This controller just cleans up toasts after their CSS animation ends.
export default class extends Controller {
  connect() {
    // Listen for new toasts appended by Turbo Stream broadcasts
    this.observer = new MutationObserver((mutations) => {
      mutations.forEach((mutation) => {
        mutation.addedNodes.forEach((node) => {
          if (node.nodeType === Node.ELEMENT_NODE) {
            const toast = node.classList?.contains("notification-toast")
              ? node
              : node.querySelector?.(".notification-toast")
            if (toast) {
              // Remove from DOM after the 5s CSS animation finishes
              setTimeout(() => toast.remove(), 5300)
            }
          }
        })
      })
    })

    const container = document.getElementById("notification-toasts")
    if (container) {
      this.observer.observe(container, { childList: true, subtree: true })
    }
  }

  disconnect() {
    this.observer?.disconnect()
  }
}
