// If you want to use Phoenix channels, run `mix help phx.gen.channel`
// to get started and then uncomment the line below.
// import "./user_socket.js"

// You can include dependencies in two ways.
//
// The simplest option is to put them in assets/vendor and
// import them using relative paths:
//
//     import "../vendor/some-package.js"
//
// Alternatively, you can `npm install some-package --prefix assets` and import
// them using a path starting with the package name:
//
//     import "some-package"
//

// Include phoenix_html to handle method=PUT/DELETE in forms and buttons.
import "phoenix_html"
// Establish Phoenix Socket and LiveView configuration.
import {Socket} from "phoenix"
import {LiveSocket} from "phoenix_live_view"
import topbar from "../vendor/topbar"

import Chart from "chart.js/auto";
import annotationPlugin from 'chartjs-plugin-annotation';

Chart.register(annotationPlugin);

let hooks = {}

hooks.ChartJS = {
  mounted() {
    const ctx = this.el

    const data = {
      type: 'line',
      data: {
        labels: JSON.parse(this.el.dataset.labels),
        datasets: JSON.parse(this.el.dataset.datasets),
      },
      options: {
        plugins: {
          annotation: {
            annotations: JSON.parse(this.el.dataset.events)
              .map(event => {
                if (event.ended_at) {
                  return {
                    type: 'box',
                    xMin: event.started_at,
                    xMax: event.ended_at,
                    borderColor: 'rgb(255, 99, 132)',
                    borderWitdht: 1,
                    backgroundColor: 'rgba(255, 99, 132, 0.25)',
                    label: {
                      content: event.label,
                      display: true,
                      position: 'start',
                      color: 'rgb(150, 150, 150)'
                    }
                  }
                }

                return {
                  type: 'line',
                  xMin: event.started_at,
                  xMax: event.started_at,
                  borderColor: 'rgb(255, 99, 132)',
                  borderWitdht: 1,
                  label: {
                    content: event.label,
                    display: true,
                    position: 'end',
                    backgroundColor: 'rgb(200, 200, 200)'
                  }
                }
              })
          }
        }
      }
    }

    const chart = new Chart(ctx, data)

    this.handleEvent('update-chart', (payload) => {
      chart.data.labels = payload.data.labels
      chart.data.datasets = payload.data.datasets

      chart.options.plugins.annotation.annotations = payload.data.events
        .map(event => {
          if (event.ended_at) {
            return {
              type: 'box',
              xMin: event.started_at,
              xMax: event.ended_at,
              borderColor: 'rgb(255, 99, 132)',
              borderWitdht: 2,
              backgroundColor: 'rgba(255, 99, 132, 0.25)',
              label: {
                content: event.label,
                display: true,
                position: 'start',
                color: 'rgb(150, 150, 150)'
              }
            }
          }

          return {
            type: 'line',
            xMin: event.started_at,
            xMax: event.started_at,
            borderColor: 'rgb(255, 99, 132)',
            borderWitdht: 2,
            label: {
              content: event.label,
              display: true,
              position: 'end',
              backgroundColor: 'rgb(200, 200, 200)'
            }
          }
        })
    })
  }
}

let csrfToken = document.querySelector("meta[name='csrf-token']").getAttribute("content")
let liveSocket = new LiveSocket("/live", Socket, {hooks: hooks, params: {_csrf_token: csrfToken}})

// Show progress bar on live navigation and form submits
topbar.config({barColors: {0: "#29d"}, shadowColor: "rgba(0, 0, 0, .3)"})
window.addEventListener("phx:page-loading-start", _info => topbar.show(300))
window.addEventListener("phx:page-loading-stop", _info => topbar.hide())

// connect if there are any LiveViews on the page
liveSocket.connect()

// expose liveSocket on window for web console debug logs and latency simulation:
// >> liveSocket.enableDebug()
// >> liveSocket.enableLatencySim(1000)  // enabled for duration of browser session
// >> liveSocket.disableLatencySim()
window.liveSocket = liveSocket
