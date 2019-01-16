import React from "react"
import ReactDOM from "react-dom"

class Hello extends React.Component {
  render() {
    return "Hello React"
  }
}

var nodes = document.getElementsByClassName("app")

for (const node of nodes) {
  ReactDOM.render(<Hello />, node)
}
