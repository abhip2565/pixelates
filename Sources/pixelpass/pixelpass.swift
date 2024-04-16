import Foundation
import base45_swift
import CoreImage
import Compression
#if canImport(UIKit)
import UIKit
public class PixelPass {
    
    public func decode(_ input: String) -> Data? {
        do {
            let base45DecodedData = try input.fromBase45()
            guard let decompressedData = Zlib().decompress(base45DecodedData) else {
                print("Error decompressing data")
                return nil
            }
            return decompressedData
        } catch {
            print("Error during Base45 decoding or decompression: \(error)")
            return nil
        }
    }
    
    public func encode(_ input: String) -> String? {
        if(input.elementsEqual(""))
        {
            return nil;
        }
        guard Zlib().compress(data:input,algorithm:COMPRESSION_ZLIB) != nil
        else {
            print("Error compressing data")
            return nil
        }
        let compressedData =  Zlib().compress(data:input,algorithm:COMPRESSION_ZLIB)
        guard let base45EncodedString = compressedData?.toBase45()
        else{
            print("Encoding error")
            return nil;
        }
        return base45EncodedString
    }
    
    public func generateQRCode(from string: String, ecc:ECC,header: String="") -> UIImage? {
        var QrText=encode(string)
        if(QrText==nil)
        {
            return nil;
        }
        else
        {
            QrText=QrText!+header;
        }
        let data = QrText?.data(using: String.Encoding.ascii)
        
        if let filter = CIFilter(name: "CIQRCodeGenerator") {
            filter.setValue(data, forKey: "inputMessage")
            filter.setValue(ecc.rawValue, forKey: "inputCorrectionLevel")
            
            if let qrImage = filter.outputImage {
                let scaleX = 500 / qrImage.extent.size.width
                let scaleY = 500 / qrImage.extent.size.height
                let transformedImage = qrImage.transformed(by: CGAffineTransform(scaleX: scaleX, y: scaleY))
                
                return UIImage(ciImage: transformedImage)
            }
        }
        
        return nil
    }
    
}
#endif


