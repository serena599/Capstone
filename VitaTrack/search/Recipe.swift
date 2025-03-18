//
//  Recipe.swift
//  RecipeSearch
//
//  Created by chris on 13/12/2024.
//

// Recipe object file. Will be detailed when data format has been confirmed.

import Foundation
import SwiftUI

//Redefine the data format and member attributes of your Recipe based on the data structure documentation provided by Alex and Jiabao
struct Recipe: Decodable {
    var recipe_ID: Int
    var recipe_name: String
    var short_instruction: String?
    var instructions: String?
    var image_URL: String = ""
    var traffic_lights: [String: String] = [:]
    var food_type: String = ""
    var source: String?
    var ingredients: [String]?
    var method: String?
    var hint: String?
    var dressing: [String]?
    var variation: String?
    var is_recommend: Bool = false
}
