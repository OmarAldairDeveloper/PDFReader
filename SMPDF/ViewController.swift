//
//  ViewController.swift
//  SMPDF
//
//  Created by Omar Aldair Romero Pérez on 1/17/19.
//  Copyright © 2019 Omar Aldair Romero Pérez. All rights reserved.
//

import UIKit
import PDFKit
import MobileCoreServices
import SafariServices

class ViewController: UIViewController, UIDropInteractionDelegate, PDFViewDelegate {
    
    let pdfView = PDFView()
   

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        pdfView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(pdfView)
        
        //Restricciones para que ocupe todo el espacio de pantalla la PDFView
        pdfView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        pdfView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        pdfView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        pdfView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        pdfView.autoScales = true
        
        
        // Agregar interacción de drop a la PDFView
        let dropInteraction = UIDropInteraction(delegate: self)
        pdfView.addInteraction(dropInteraction)
        
        
        // Agregar PDFViewDelegate
        self.pdfView.delegate = self
        
        // Botones de la navigationItem
        let search = UIBarButtonItem(barButtonSystemItem: .search, target: self, action: #selector(searchText))
        let action = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(shareSelection(sender:)))
        let next = UIBarButtonItem(barButtonSystemItem: .fastForward, target: self.pdfView, action: #selector(PDFView.goToNextPage(_:)))
        let previous = UIBarButtonItem(barButtonSystemItem: .rewind, target: self.pdfView, action: #selector(PDFView.goToPreviousPage(_:)))
        self.navigationItem.leftBarButtonItems = [search, action, previous, next]
        
    
        
        
    }
    
    
    // MARK: UIDropInteractionDelegate
    func dropInteraction(_ interaction: UIDropInteraction, sessionDidUpdate session: UIDropSession) -> UIDropProposal {
        return UIDropProposal(operation: .copy)
    }
    
    func dropInteraction(_ interaction: UIDropInteraction, performDrop session: UIDropSession) {
        
        // Si lo que hemos arrastrado es un PDF, entonces entrar a la condición
        if session.hasItemsConforming(toTypeIdentifiers: [kUTTypePDF as String]){
            
            // Cargar los objetos que hemos arrastrado en forma de PDFDocumentClass
            session.loadObjects(ofClass: PDFDocumentClass.self) { (items) in
            
                // Obtener el primer objeto arrastrado
                guard let pdfDoc = items.first as? PDFDocumentClass else { return }
                
                // Obtener la data de ese documento y así podemos contruir el PDFDocument
                if let data = pdfDoc.data{
                    self.openPDF(data: data)
                }

            }
            print("SI es PDF")
        }else{
            
            print("NO es PDF")
        }
    }
    
    // MARK: PDFViewDelegate
    func pdfViewWillClick(onLink sender: PDFView, with url: URL) {
        // Abrir Safari al clickear en un vínculo dentro del pdf
        let safariController = SFSafariViewController(url: url)
        safariController.modalPresentationStyle = .formSheet
        present(safariController, animated: true)
    }
    
    // MARK: Manage PDF
    func openPDF(data: Data){
        // Crear el PDFDocument y asignarlo a la PDFView
        if let document = PDFDocument(data: data){
            self.pdfView.document = document
            self.pdfView.goToFirstPage(nil)
        }
        
    }
    
    @objc func searchText(){
        
        // Crear un alert controller con un textfield para buscar palabras dentro del documento
        let alert = UIAlertController(title: "Buscar texto", message: "", preferredStyle: .alert)
        
        alert.addTextField { (txtField) in
            txtField.placeholder = "Escribe las palabras clave que deseas buscar"
        }
        
        alert.addAction(UIAlertAction(title: "Buscar", style: .default, handler: { (action) in
            guard let text = alert.textFields?.first?.text else { return }
            
            // Coincidencias
            guard let matches = self.pdfView.document?.findString(text, withOptions: .caseInsensitive) else { return }
            
            // Recorrer coincidencias y luego sus páginas para colorear esas coincidencias de color rojo
            matches.forEach({ (match) in
                match.pages.forEach({ (page) in
                    let highlight = PDFAnnotation(bounds: match.bounds(for: page), forType: .highlight, withProperties: nil)
                    highlight.endLineStyle = .circle
                    highlight.color = UIColor.red
                    
                    page.addAnnotation(highlight)
                })
            })
            
            // Ir al primer match
            if let firstMatch = matches.first{
                self.pdfView.go(to: firstMatch)
            }
            

   
        }))
        
        alert.addAction(UIAlertAction(title: "Cancelar", style: .cancel, handler: nil))
        
        present(alert, animated: true)
    }
    
    
    
    
    @objc func shareSelection(sender: UIBarButtonItem){
        
        
        guard let selection = self.pdfView.currentSelection?.attributedString else{
            let alert = UIAlertController(title: "No hay nada seleccionado", message: "Selecciona una parte del PDF", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            present(alert, animated: true)
            return
        }
        
        // Compartir texto seleccionado a través de otras aplicaciones
        let sharedVC = UIActivityViewController(activityItems: [selection], applicationActivities: nil)
        sharedVC.popoverPresentationController?.barButtonItem = sender
        present(sharedVC, animated: true)
    }
    
    
    
    
    
    


}

