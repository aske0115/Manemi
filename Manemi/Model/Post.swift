//
//  Post.swift
//  Manemi
//
//  Created by 1101249 on 11/13/22.
//

struct Post: Identifiable, Codable, Equatable
{
    var id: Int
    var post: String
    var images: [String]?
}
