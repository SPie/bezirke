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
import * as echarts from 'echarts'

import hooks from './hooks';

let format_date = (date) => (new Date(date)).toLocaleDateString('de-DE', {day: "2-digit", month: "2-digit", year: "numeric"});

hooks.Chart = {
  mounted() {
    this.chart = echarts.init(this.el)

    function processTicketCounts(ticketCounts) {
      return ticketCounts
        .map(item => ([
          new Date(item.date),
          item.tickets_count,
        ]))
    }

    function processSeriesData(datasets) {
      return datasets
        .map(item => ({
          name: item.label,
          type: 'line',
          showSymbol: true,
          symbolSize: 6,
          data: processTicketCounts(item.ticket_counts),
          emphasis: {
            focus: 'series',
          },
          lineStyle: {
            width: 2,
          },
          // Add markers here markLine: commonMarkLine,
          // markLine: commonMarkLine,
          // markArea: commonMarkArea,
        }))
    }

    function createOptions(datasets) {
      const datasetsSeries = processSeriesData(datasets)

      // Define the marker configurations once to avoid repetition inside the option
      // const commonMarkLine = {
      //   symbol: ['none', 'none'],
      //   lineStyle: {
      //     type: 'dashed',
      //     color: '#e63946',
      //   },
      //   label: {
      //     show: true,
      //     position: 'end',
      //     formatter: '{b}',
      //   },
      //   data: [
      //     {
      //       name: 'Test1',
      //       xAxis: '2025-01-07',
      //     },
      //   ]
      // };
      // const commonMarkArea = {
      //   label: {
      //     show: true,
      //     position: 'insideTop',
      //     distance: 15,
      //     color: '#333',
      //     fontSize: 12,
      //     formatter: '{b}',
      //   },
      //   data: [
      //     [
      //       {
      //         name: 'Test2',
      //         xAxis: '2025-02-10',
      //         itemStyle: {
      //           color: 'rgba(168, 218, 220, 0.4)',
      //         },
      //       },
      //       {
      //         xAxis: '2025-02-17',
      //       },
      //     ],
      //     [
      //       {
      //         name: 'Test3',
      //         xAxis: '2025-01-06',
      //         itemStyle: {
      //           color: 'rgba(255, 186, 84, 0.4)',
      //         },
      //       },
      //       {
      //         xAxis: '2025-01-11',
      //       },
      //     ],
      //     [
      //       {
      //         name: 'Test4',
      //         xAxis: '2025-02-06',
      //         itemStyle: {
      //           color: 'rgba(144, 221, 176, 0.4)',
      //         },
      //       },
      //       {
      //         xAxis: '2025-02-13',
      //       },
      //     ]
      //   ]
      // };
      return {
        tooltip: {
          trigger: 'axis',
          axisPointer: { type: 'cross', label: { backgroundColor: '#6a7985' } },
          formatter: function (params) {
            const actualSeriesParams = params;

            if (!actualSeriesParams.length) return null;

            const point = actualSeriesParams[0];

            const date = new Date(point.value[0]);

            const formattedDate = `${('0' + date.getDate()).slice(-2)}.${('0' + (date.getMonth() + 1))
                .slice(-2)}.${date.getFullYear()}`;
            let tooltipHtml = formattedDate; actualSeriesParams.forEach(p => {
              tooltipHtml += `<br/>${p.marker}${p.seriesName}: <strong>${p.value[1]}</strong>`;
            });
            return tooltipHtml;
          },
        },
        legend: {
          top: 'top',
        },
        grid: {
          left: '1%',
          right: '1%',
          bottom: '7%',
          containLabel: true,
        },
        xAxis: {
          type: 'time',
          boundaryGap: false,
        },
        yAxis: {
          type: 'value',
          axisLabel: { formatter: '{value}' },
        },
        dataZoom: [
          {
            type: 'inside',
            start: 0,
            end: 100,
          },
        ],
        series: datasetsSeries,
      };
    }

    this.chart.setOption(createOptions(JSON.parse(this.el.dataset.datasets)));

    this.handleEvent('update-chart', (payload) => {
      this.chart.setOption(createOptions(payload.data.datasets), { notMerge: true })
    })

    window.addEventListener('resize', () => {
      this.chart.resize();
    });
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
