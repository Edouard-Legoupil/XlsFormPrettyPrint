# WARNING - Generated by {fusen} from /dev/dev_doc_fusen.Rmd: do not edit by hand

#' @title Combine the xlsform in single table for pretty printing
#'
#' @param xlsformpath path to the file with xlsform
#' @param label_language Language to be used in case you have more than one. 
#' If not specified, the 'default_language' in the 'settings' worksheet is used.
#'  If that is not specified and more than one language is in the XlsForm, 
#'  the language that comes first within column order will be used.
#' 
#' @importFrom readxl read_excel
#' @importFrom dplyr rename mutate recode first distinct select left_join filter
#' @importFrom tidyselect starts_with
#' @importFrom tidyr separate
#' @importFrom stringr str_replace_all
#' 
#' @return a single data frame
#' @export
#' 
#' @examples
#' # tabulate_form()
#' 
#' prettyform <- tabulate_form( xlsformpath = system.file("demo.xlsx", package = "XlsFormPrettyPrint") )
#' 
#' knitr::kable(utils::head(prettyform, 10))
#' 
tabulate_form <- function(xlsformpath,
                          label_language = NULL) {

  
  # Additional Test
  # xlsformpath <- "inst/RMS_CAPI_v2_en_es_fr.xlsx"
  # label_language <- "Espa<f1>ol (es)"
  # label_language <- "Fran<e7>ais (fr)"
  # label_language <- "English (en)" 
  
  survey <- readxl::read_excel(xlsformpath, sheet = "survey")
  
  choices <- readxl::read_excel(xlsformpath, sheet = "choices") 
  
  settings <- readxl::read_excel(xlsformpath,  sheet = "settings")
  
 
  
  ## Check if a default language is set up in the settings - and add the correct separator
  # for test settings$default_language <- NULL
  label_language <- ifelse( is.null(label_language),
                                      ifelse( is.null(settings$default_language), 
                                             label_language, 
                                             paste0("::",settings$default_language)),
                                     paste0("::",label_language))
  #label_language 
  
  modalities <- choices |>
      ## Rename and use what ever label set is coming first 
      dplyr::rename(labelmod = ifelse( is.null(label_language),
                                       dplyr::first(tidyselect::starts_with("label")), 
                                       paste0("label",label_language))  ,
                    namemod = name)  |>
      dplyr::filter( !(is.na(list_name)))  |> 
      dplyr::mutate(labelnamemod = paste0("-[",namemod,"] ",labelmod))  |>
    ## Calculate number modalities per list_name - if more than 8 - then we assume that
    ## those modalities will not be read by the enumerator and not be accounted for the interview duration estimation
     
                        dplyr::select(list_name, labelnamemod)|> 
                        dplyr::group_by(list_name) |> 
                        dplyr::mutate(new_list = paste(labelnamemod, 
                                                collapse="\n")) |> 
                        dplyr::group_by(list_name) |>
                      ## remove defacto dpuplicate..
                        dplyr::mutate(id = dplyr::row_number()) |>
                        dplyr::mutate(new_list  = ifelse(test = id == 1,
                                                  yes  = new_list,
                                                  no   = NA)) |>
                        dplyr::filter(!is.na(new_list)) |> 
                        dplyr::select(list_name, new_list) |>
                        dplyr::ungroup() |>
    ## if the list of modalities is super long - trim it for better printing...
    dplyr::mutate( new_list =  ifelse(test = nchar(new_list) >= 500,
                                        yes  = paste0(substr(new_list,1,500),
                                                      " \n ---- AND SO ON - long list... "),
                                        no   = new_list) )
  
  variables_temp  <-  survey  |>
      dplyr::filter( !(is.na(type)))|>
      ## Rename and use what ever label set is coming first 
      dplyr::rename(label = ifelse( is.null(label_language), dplyr::first(tidyselect::starts_with("label")), paste0("label",label_language)),
                    hint =  ifelse( is.null(label_language), dplyr::first(tidyselect::starts_with("hint")), paste0("hint",label_language)) ,
                    constraint_message =  dplyr::first(tidyselect::starts_with("constraint_message"))
                   # constraint_message = ifelse( is.null(label_language), dplyr::first(tidyselect::starts_with("constraint_message")), paste0("constraint_message",label_language))
                    
                    ) |>
      
      
      # Clean the begin and end in case the _ would be missing...
      dplyr::mutate(type = dplyr::recode(type, 
                                          "begin group" = "begin_group" ,
                                          "end group"   ="end_group",
                                         "begin repeat" = "begin_repeat" ,
                                         "end repeat"   ="end_repeat")) |>
      
      ## spearate the type
      tidyr::separate(type, 
                          into = c("type", "list_name"), 
                          sep = " ",
                          fill = "right")   |>
      
      # dplyr::mutate(name_type = glue::glue('{name} \n *(type: {type})')) |>
      # dplyr::mutate(label_hint = glue::glue('{label} \n *(hint: {hint})')) |>
      #dplyr::mutate(name_type = paste0(name, "\n *(type: ",type, ")")) |>
    
      # stripping all the HTML code
      dplyr::mutate(label  = gsub("#", "", label)) |>
      dplyr::mutate(label  = gsub("@", "[at]", label)) |>
      dplyr::mutate(label  = gsub("<(.|\n)*?>", "", label)) |>
      dplyr::mutate(label  = gsub("\\*", "", label)) |>
    
      ## Adding hint with label
      dplyr::mutate(label_hint = paste0( 
                                  #ifelse(is.na(label), "no label", label),
                                  ifelse(is.na(label), "", label),
                                  ifelse(is.na(hint), "", 
                                                 paste0("\n *(hint: ", hint, ")") 
                                                 ) )) |>
    
    
    ## Make the relevant expression more legible
      ## Case relevant if not null...
      dplyr::mutate(relevant = stringr::str_replace_all( relevant,
                                                         pattern = "''",
                                                         replacement = "NULL")) |>
      dplyr::mutate(relevant = stringr::str_replace_all( relevant,
                                                         pattern = "!=",
                                                         replacement = " is not ")) |>
      dplyr::mutate(relevant = ifelse(is.na(relevant), 
                                       relevant, 
                                       paste0(name, " is relevant if ", stringr::str_replace_all( relevant,
                                                        # pattern = c( "(", "\\$", "{", "}", ")" ),
                                                        pattern = "[^[:alnum:][:blank:]+?><=_&/\\-]",
                                                         replacement = "")) )) |>
    
    ## Make the constraint expression more legible
     # dplyr::mutate(instruct = glue::glue('{relevant} \n *(constraint: {constraint_message})')) |>
      dplyr::mutate(instruct = paste0( 
                                  ifelse(is.na(relevant), "", relevant),
                                  ifelse(is.na(constraint_message), "", 
                                                 paste0("\n Constraint on ", name,": ", constraint_message, ")") 
                                                 ) )) |>
      
    ## Need to add more cleaning in case...
      dplyr::filter(!(is.na(type))) |>
      dplyr::filter(type != "calculate") |>  
      dplyr::select(name, type ,label_hint,  instruct, list_name )
  
variables <- variables_temp   |>
    
    ## Now merge with modalities
      dplyr::left_join(modalities |>  
                      dplyr::select(list_name, new_list ),
                      by = c("list_name")) |>
      ## Add the type in the new list
      dplyr::mutate( new_list = ifelse(test = is.na(new_list),
                      yes  = paste0( "( type: ", type,")"  ),
                      no   =  paste0( "( type: ", type,") \n", new_list  ) )) |>
      dplyr::select(label_hint, new_list, name ,  instruct) |>
      #dplyr::distinct() |>
      ## Rename and use what ever label set is coming first 
      dplyr::rename( Questions = label_hint,
                     Choices = new_list,
                     Variables =  name,
                     Logic =  instruct)
    
    return(variables)
    
}
 

