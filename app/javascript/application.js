// app/javascript/application.js
import { Turbo } from "@hotwired/turbo-rails"
Turbo.session.drive = false

document.addEventListener("turbo:load", () => {
  const logoutLinks = document.querySelectorAll("a[data-turbo-method='delete']")
  logoutLinks.forEach(link => {
    link.addEventListener("click", (e) => {
      e.preventDefault()
      const form = document.createElement("form")
      form.method = "POST"
      form.action = link.href
      const methodInput = document.createElement("input")
      methodInput.type = "hidden"
      methodInput.name = "_method"
      methodInput.value = "delete"
      form.appendChild(methodInput)
      document.body.appendChild(form)
      form.submit()
    })
  })
})