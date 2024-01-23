//
//  DataModel.swift
//  BirdsApp
//
//  Created by MacBook Pro on 18/12/2023.
//

import Foundation
import UIKit

var strForLogin = "isUserLogedIn"

struct User : Decodable {
    
    let firstname : String
    let lastname : String
    let Email : String
    var ProfileImageURL : String
    let Password : String
    let BirdsApp : [String: Bird]?
    let ExpireData : [String: Bird]?
    let SoldData: [String: Bird]?
}

struct Bird : Codable {
    
    let userId: String
    
    let accuracy : String
    let bird_ID : String
    let bird_Specie : String
    let certificate_No : String
    let collection : String
    let owner_Name : String
    let sample_Type : String
    let sex_Determination : String
    let uploadCurrentImage : String
    let upload_Date : String
    var buyer_Name : String
    var buyer_Phone_Number : String
    var latest_Sold_Date: String

    enum CodingKeys: String, CodingKey {

        case accuracy = "Accuracy"
        case userId = "UserId"
        case bird_ID = "Bird_ID"
        case bird_Specie = "Bird_Specie"
        case certificate_No = "Certificate_No"
        case collection = "Collection"
        case owner_Name = "Owner_Name"
        case sample_Type = "Sample_Type"
        case sex_Determination = "Sex_Determination"
        case uploadCurrentImage = "UploadCurrentImage"
        case upload_Date = "Upload_Date"
        case buyer_Name
        case buyer_Phone_Number
        case latest_Sold_Date
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)

        accuracy = try values.decodeIfPresent(String.self, forKey: .accuracy) ?? ""
        userId = try values.decodeIfPresent(String.self, forKey: .userId) ?? ""
        bird_ID = try values.decodeIfPresent(String.self, forKey: .bird_ID) ?? ""
        bird_Specie = try values.decodeIfPresent(String.self, forKey: .bird_Specie) ?? ""
        certificate_No = try values.decodeIfPresent(String.self, forKey: .certificate_No) ?? ""
        collection = try values.decodeIfPresent(String.self, forKey: .collection) ?? ""
        owner_Name = try values.decodeIfPresent(String.self, forKey: .owner_Name) ?? ""
        sample_Type = try values.decodeIfPresent(String.self, forKey: .sample_Type) ?? ""
        sex_Determination = try values.decodeIfPresent(String.self, forKey: .sex_Determination) ?? ""
        uploadCurrentImage = try values.decodeIfPresent(String.self, forKey: .uploadCurrentImage) ?? ""
        upload_Date = try values.decodeIfPresent(String.self, forKey: .upload_Date) ?? ""
        buyer_Name = try values.decodeIfPresent(String.self, forKey: .buyer_Name) ?? ""
        buyer_Phone_Number = try values.decodeIfPresent(String.self, forKey: .buyer_Phone_Number) ?? ""
        latest_Sold_Date = try values.decodeIfPresent(String.self, forKey: .latest_Sold_Date) ?? ""
    }


}
struct ExpiredBird: Codable {
    let accuracy: String
    let birdID: String
    let birdSpecie: String
    let certificateNo: String
    let collection: String
    let ownerName: String
    let sampleType: String
    let sexDetermination: String
    let uploadCurrentImage: String
    let uploadDate: String
    let Sold_or_Expire : String

    enum CodingKeys: String, CodingKey {
        case accuracy = "Accuracy"
        case birdID = "Bird_ID"
        case birdSpecie = "Bird_Specie"
        case certificateNo = "Certificate_No"
        case collection = "Collection"
        case ownerName = "Owner_Name"
        case sampleType = "Sample_Type"
        case sexDetermination = "Sex_Determination"
        case uploadCurrentImage = "UploadCurrentImage"
        case uploadDate = "Upload_Date"
        case Sold_or_Expire = "Sold_or_Expire"
        
    }
}

struct SoldBird: Codable {
    let accuracy: String
    let birdID: String
    let birdSpecie: String
    let certificateNo: String
    let collection: String
    let ownerName: String
    let sampleType: String
    let sexDetermination: String
    let uploadCurrentImage: String
    let uploadDate: String
    let buyerName: String
    let buyerPhoneNumber: String
    let Sold_or_Expire : String

    enum CodingKeys: String, CodingKey {
        case accuracy = "Accuracy"
        case birdID = "Bird_ID"
        case birdSpecie = "Bird_Specie"
        case certificateNo = "Certificate_No"
        case collection = "Collection"
        case ownerName = "Owner_Name"
        case sampleType = "Sample_Type"
        case sexDetermination = "Sex_Determination"
        case uploadCurrentImage = "UploadCurrentImage"
        case uploadDate = "Upload_Date"
        case buyerName = "buyer_Name"
        case buyerPhoneNumber = "buyer_Phone_Number"
        case Sold_or_Expire = "Sold_or_Expire"
    }
}
