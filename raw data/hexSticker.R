# https://github.com/GuangchuangYu/hexSticker

library(hexSticker)

sticker(
  expression(plot(
    cars,
    cex = .5,
    cex.axis = .5,
    mgp = c(0, .3, 0),
    xlab = "",
    ylab = ""
  )),
  package = "treeSimR",
  p_size = 25,
  s_x = 0.8,
  s_y = .6,
  s_width = 2.0,
  s_height = 1.3,
  filename = "hexSticker.png"
)


imgurl <- "data/hexSticker_fig.png"
sticker(
  imgurl,
  package = "treeSimR",
  p_size = 25,
  s_x = 1,
  s_y = .75,
  s_width = .6,
  filename = "hexSticker.png"
)
