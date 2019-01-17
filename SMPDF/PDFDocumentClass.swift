//
//  PDFDocument.swift
//  SMPDF
//
//  Created by Omar Aldair Romero Pérez on 1/17/19.
//  Copyright © 2019 Omar Aldair Romero Pérez. All rights reserved.
//

import Foundation
import MobileCoreServices

class PDFDocumentClass: NSObject, NSItemProviderReading {
    let data: Data?
    
    required init(pdfData: Data, typeIdentifier: String) {
        data = pdfData
    }
    
    static var readableTypeIdentifiersForItemProvider: [String] {
        return [kUTTypePDF as String]
    }
    
    static func object(withItemProviderData data: Data, typeIdentifier: String) throws -> Self {
        return self.init(pdfData: data, typeIdentifier: typeIdentifier)
    }
}
