# utils.R -----
my_theme <- function() {
  list(
    scale_x_date(expand = c(0, 0)),
    scale_y_continuous(labels = function(x) {
      format(x, big.mark = " ")
    }),
    xlab(""),
    ylab(""),
    ggthemes::theme_economist(),
    theme(
      plot.title      = element_text(size = 18, margin = margin(0, 0, 8, 0)),
      axis.title.x    = element_blank(),
      axis.ticks.x    = element_blank(),
      axis.text.x     = element_text(angle = 90, vjust = 0.5, hjust = 1),
      axis.title.y    = element_text(vjust = 3.5),
      legend.position = "bottom",
      legend.title    = element_blank()
    ),
    annotate(
      geom = "text", label = "Source <https://exchangerate.host/>",
      x = structure(Inf, class = "Date"), y = -Inf,
      hjust = 1.1, vjust = -0.4, col = "grey",
      fontface = "italic"
    )
  )
}