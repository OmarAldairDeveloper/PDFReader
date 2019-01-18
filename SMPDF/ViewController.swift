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

class ViewController: UIViewController, UIDropInteractionDelegate {
    
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
        
        // Agregar interacción de drop a la PDFView
        let dropInteraction = UIDropInteraction(delegate: self)
        pdfView.addInteraction(dropInteraction)
        
        
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
        
        if session.hasItemsConforming(toTypeIdentifiers: [kUTTypePDF as String]){
            
            session.loadObjects(ofClass: PDFDocumentClass.self) { (items) in
            
                guard let pdfDoc = items.first as? PDFDocumentClass else { return }
                
                if let data = pdfDoc.data{
                    self.openPDF(data: data)
                }

            }
            print("SI es PDF")
        }else{
            
            print("NO es PDF")
        }
    }
    
    // Manage PDF
    func openPDF(data: Data){
        
        if let document = PDFDocument(data: data){
            self.pdfView.document = document
            self.pdfView.goToFirstPage(nil)
        }
        
    }
    
    @objc func searchText(){
        
        let alert = UIAlertController(title: "Buscar texto", message: "", preferredStyle: .alert)
        
        alert.addTextField { (txtField) in
            txtField.placeholder = "Escribe las palabras clave que deseas buscar"
        }
        
        alert.addAction(UIAlertAction(title: "Buscar", style: .default, handler: { (action) in
            
            guard let text = alert.textFields?.first?.text else { return }
            guard let match = self.pdfView.document?.findString(text, fromSelection: self.pdfView.highlightedSelections?.first, withOptions: .caseInsensitive) else { return }
            
            match.color = UIColor.red
            self.pdfView.go(to: match)
            self.pdfView.highlightedSelections = [match]
            
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
        
        let sharedVC = UIActivityViewController(activityItems: [selection], applicationActivities: nil)
        sharedVC.popoverPresentationController?.barButtonItem = sender
        present(sharedVC, animated: true)
    }
    
    
    
    


}

