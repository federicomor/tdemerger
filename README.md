# Breve descrizione

Script che unisce temi d'esame/dispense/esercitazioni in un unico pdf indicizzato.

## Istruzioni per l'esecuzione

**Requisiti**: aver installato pdflatex (cioè aver installato TexStudio o un programma simile sul vostro pc)

**Istruzioni**:

1. Scaricare il file *tdemerger.ps1* e metterlo nella cartella in cui si trovano i pdf da unire.

2. Aprire Windows PowerShell cercando Powershell nel menù di Windows, o Windows Terminal (sempre cercando il nome dal menù di Windows).

Consiglio generale: provate a schiacciare Tab mentre digitate, vi autocompleterà le parole.

3. Spostarsi nella cartella in cui si vogliono unire i pdf, con il comando:
```
cd Percorso\verso\la\cartella
```
Altrimenti selezionare la cartella in cui si vuole lanciare lo script, poi cliccarci sopra col tasto destro, e infine selezionare l'opzione che permette di aprirla in Windows PowerShell o Windows Terminal.

4. Lanciare il comando:
```
Powershell.exe -executionpolicy remotesigned -File  .\tdemerger.ps1
```
per eseguire lo script.

## Risultato

![risultato](s1.png)
![risultato](s2.png)
![risultato](s3.png)
