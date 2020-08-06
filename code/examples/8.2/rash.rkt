#lang rash

(require csv-reading racket/list)

(read-decimal-as-inexact #f)

cd finances
cat purchases.csv |> csv->list =bind= purchases |> take _ 3
|> rest purchases |> map fourth |> map string->number |> apply + |> exact->inexact
