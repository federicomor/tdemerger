# Short description

Script that merges exams/lecture notes/exercises in a single and indexed pdf.

## Instructions for execution

**Requirements**: have installed pdflatex (i.e. have installed TexStudio or a similar software on your pc)

**Instructions**:

1. Download the file *tdemerger_en.ps1* and put it in the folder where there are the pdfs to be merged.

2. Open Windows PowerShell by searching Powershell in the Windows menu, or the Windows Terminal (also looking for it from the Windows menu).

General tip: try hitting Tab as you type, it will auto-complete your words.

3. Move to the folder where you want to merge the pdf, with the command:
```
cd Path\to\the\folder
```
Otherwise, select the folder in which you want to launch the script, then right-click it, and finally select the option that allows you to open it in Windows PowerShell or Windows Terminal.

4. Run the command:
```
Powershell.exe -executionpolicy remotesigned -File .\tdemerger.ps1
```
to run the script.

## Result

![result](s1.png)
Text: various pdfs of exams, downloaded form Beep.
![result](s2.png)
Text: exectution of the script.
![result](s3.png)
Text: each pdf file has now become a chapter of a unique pdf.