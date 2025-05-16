import * as echarts from 'echarts'

const Chart = {
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
        }))
    }

    function createOptions(datasets) {
      const datasetsSeries = processSeriesData(datasets)

      return {
        tooltip: {
          trigger: 'axis',
          type: 'axis',
        },
        legend: {
          bottom: 0,
          type: 'scroll'
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
      }
    }

    this.chart.setOption(createOptions(JSON.parse(this.el.dataset.datasets)))

    this.handleEvent('update-chart', (payload) => {
      this.chart.setOption(createOptions(payload.data.datasets), { notMerge: true })
    })

    this.handleEvent('set-chart-events', (payload) => {
      let markLineEvents = []
      let markAreaEvents = []

      payload.data.events.forEach(event => {
        if (event.started_at == event.ended_at) {
          markLineEvents.push({
            name: event.label,
            xAxis: new Date(event.started_at)
          })
        } else {
          markAreaEvents.push([
            {
              name: event.label,
              xAxis: new Date(event.started_at)
            },
            {
              xAxis: new Date(event.ended_at)
            }
          ])
        }
      })

      const commonMarkLine = {
        symbol: ['none', 'none'],
        lineStyle: {
          type: 'dashed',
          color: '#e63946',
        },
        animation: false,
        label: {
          show: false,
          position: 'end',
          formatter: '{b}',
        },
        emphasis: {
          label: {
            show: true,
          }
        },
        data: markLineEvents
      };
      const commonMarkArea = {
        label: {
          show: false,
          position: 'insideTop',
          distance: 15,
          color: '#333',
          fontSize: 12,
          formatter: '{b}',
        },
        emphasis: {
          label: {
            show: true,
          }
        },
        data: markAreaEvents,
        itemStyle: {
          opacity: 0.1,
          color: '#f08080'
        }
      };

      let seriesWithEvents = this.chart.getOption().series.map(dataset => {
        dataset.markLine = commonMarkLine
        dataset.markArea = commonMarkArea

        return dataset
      })

      this.chart.setOption({ series: seriesWithEvents });
    })

    window.addEventListener('resize', () => {
      this.chart.resize()
    })
  }
}

export default Chart
