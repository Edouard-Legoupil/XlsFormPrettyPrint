
# An `RMD` template to convert a survey questionnaire from a master `XlsForm` to a `Word` version for easy review

When customizing and adjusting a household survey questionnaire during the design phase, it's often necessary to have one testing version (i.e. encoded in [xlsform](http://xlsform)) and a more legible version in word that can be then shared with non-technical experts for them to comment and review.

Moving between a paper version and an encoded-machine ready version is not smooth. Instead of having the master version in word and updating once while the xlsform, it's more convenient to generate a word output to collect feedback in word tracking mode.

`{XlsFormPrettyPrint}` is a small utility to quickly generate a nicely printed version in word of a master version in xlsform. This way all comments from the circulated version can be easily re-injected back in the master without loosing all the coding.

The default _prettyprinting_ template brings in a single grid different parts of the xlsform. The _prettyprinting_ can be done separately for each different language in case the `xlsform` includes more than one. The template increases legibility for both __question blocks__:

  1. begin_group --> depending on the level are output with a different style of heading level
  2. begin_repeat --> displayed as a header but with a specific distinct color and note

and within each block, each __question details__ is  included:  

  1. question code & type
  2. question label & hint
  3. if select_one or select_multiple, modalities code and label as a nested table
  4. if present - question constraint with warning message as well as related question skip logic

In addition, the package includes a function to come up with an estimation of the interview duration time, a critical element to consider to ensure high quality data.

## Install  the package

```
remotes::install_github('vidonne/unhcrdown')
remotes::install_github('vidonne/unhcrdesign')
remotes::install_github('vidonne/unhcrtemplate')
remotes::install_github('Edouard-Legoupil/XlsFormPrettyPrint')  
```

## Quick start

One `{XlsFormPrettyPrint}` installed, you can create a new RMD using the custom template.

Using [RStudio](https://www.rstudio.com/):

 * Step 1: Click the "File" menu then "New File" and choose "R Markdown".

 * Step 2: In the "From Template" tab, choose one of the built-in templates.

You will then just need to fill in the [YAML parameters](https://rmarkdown.rstudio.com/lesson-6.html):

 *  `dir`:  the directory in which to find the xlsform and where to save the output file (absolute path or relative to current working directory).
 
 *  `xlsformfile`:  Name of the questionnaire file as character. The package is not designed to validate your xlsform. Please use xlsform validator beforehand.
    
 *  `label_language`:  Language to be used in case you have more than one. If not specified, the 'default_language' in the 'settings' worksheet is used. If that is not specified and more than one language is in the XlsForm, the language that comes first within column order will be used. 
 
You can check and example here: the [xlsform](https://github.com/Edouard-Legoupil/XlsFormPrettyPrint/blob/master/inst/demo.xlsx?raw=true) and the resulting [word](https://github.com/Edouard-Legoupil/XlsFormPrettyPrint/blob/master/inst/skeleton.docx?raw=true)    

## Reference

The package mostly leverages the capacity of the [{flextable}](https://ardata-fr.github.io/flextable-book/layout.html) package and embed UNHCR template from [{unhcrdown}](https://vidonne.github.io/unhcrdown/).

Another R package [https://github.com/hedibmustapha/QuestionnaireHTML](https://github.com/hedibmustapha/QuestionnaireHTML) was built with the same goal but with a limited scope and styling capacity. There's also from a similar project in python: [https://github.com/pmaengineering/ppp](https://github.com/pmaengineering/ppp)


