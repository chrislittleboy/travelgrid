mosaic_rasters <- function(x, batch_size = 50, name) {

  stopifnot(length(x) > 0, batch_size >= 2)

  tmp_dir <- tempfile("merge_rasters_")
  dir.create(tmp_dir)

  on.exit(unlink(tmp_dir, recursive = TRUE), add = TRUE)

  if (inherits(x, "SpatRaster")) {
    x <- list(x)
  }

  round <- 1

  while (length(x) > 1) {

    message("Round ", round, ": ", length(x), " rasters")

    groups <- split(
      seq_along(x),
      ceiling(seq_along(x) / batch_size)
    )

    x_new <- vector("list", length(groups))

    for (i in seq_along(groups)) {

      message("  Batch ", i, "/", length(groups))

      out <- if (length(groups) == 1) {
        name
      } else {
        file.path(
          tmp_dir,
          paste0("round_", round, "_batch_", i, ".tif")
        )
      }

      r <- mosaic(sprc(x[groups[[i]]]), fun = "max",
                   filename = out)

    }

    x <- x_new
    round <- round + 1
  }

  x[[1]]
}
