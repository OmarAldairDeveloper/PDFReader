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
    
    
    func openPDF(data: Data){
        
        if let document = PDFDocument(data: data){
            
            self.pdfView.document = document
            self.pdfView.goToFirstPage(nil)
        }
        
    }


}

