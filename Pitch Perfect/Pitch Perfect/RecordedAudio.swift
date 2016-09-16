//
//  RecordedAudio.swift
//  Pitch Perfect
//
//  Created by Daniel Riehs on 3/6/15.
//  Copyright (c) 2015 Daniel Riehs. All rights reserved.
//

import Foundation

class RecordedAudio: NSObject{
	var filePathUrl: URL!
	var title: String!

	init(filePathUrl: URL, title: String) {
		self.filePathUrl = filePathUrl
		self.title = title
	}
}
