# 


#' Scans all the .afm files and saves a csv file with information about them.
#' @export
afm_save_table <- function() {
  afmdata <- afm_scan_files()

  message("Saving afm table in ", afm_table_file())
  write.csv(afmdata, file = afm_table_file(), row.names = FALSE)
}


# Reads all the .afm files and builds a table of information about them. 
afm_scan_files <- function() {
  message("Scanning afm files in ", afm_path())
  afmfiles <- normalizePath(list.files(afm_path(), pattern = "\\.afm$", full.names=TRUE))

  # Build a table of information of all the afm files
  afmdata <- lapply(afmfiles, afm_get_info)
  afmdata <- do.call(rbind, afmdata)

  afmdata
}


# Read in font information from an .afm file
afm_get_info <- function(filename) {
  fd <- file(filename, "r")
  text <- readLines(fd, 30)  # Reading 30 lines should be more than enough
  close(fd)

  # Pull out the font names from lines like this:
  # FamilyName Arial
  # FontName Arial-ItalicMT
  # FullName Arial Italic
  FamilyName <- sub("^FamilyName ", "", text[grepl("^FamilyName", text)])
  FontName   <- sub("^FontName ",   "", text[grepl("^FontName",   text)])
  FullName   <- sub("^FullName ",   "", text[grepl("^FullName",   text)])

  # Read in the Weight field and figure out of it's Bold and/or Italic
  weight <- sub("^Weight ",   "", text[grepl("^Weight",   text)])
  if (grepl("Bold",   weight))  Bold = TRUE
  else                          Bold = FALSE

  if (grepl("Italic", weight))  Italic = TRUE
  else                          Italic = FALSE

  if (grepl("Oblique", weight)) Oblique = TRUE
  else                          Oblique = FALSE

  data.frame(FamilyName, FontName, FullName, afmfile = basename(filename),
             Bold, Italic, Oblique, stringsAsFactors = FALSE)
}

#' @export
afm_load_table <- function() {
  read.csv(afm_table_file(), stringsAsFactors = FALSE)
}
