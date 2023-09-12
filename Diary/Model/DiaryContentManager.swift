//
//  DiaryContentManager.swift
//  Diary
//
//  Created by Dasan, kyungmin on 2023/09/12.
//

import Foundation

struct DiaryContentManager {
    func convert(with text: String, _ diary: Diary) -> Diary {
        var textComponents = text.components(separatedBy: NameSpace.splitFormat)

        let title = textComponents.removeFirst()
        let body = textComponents.reduce("") { partialResult, element in
            return partialResult + "\n" + element
        }

        return diary
    }
    
    func convert(with text: String) -> (String, String) {
        var textComponents = text.components(separatedBy: NameSpace.splitFormat)

        let title = textComponents.removeFirst()
        let body = textComponents.reduce("") { partialResult, element in
            return partialResult + "\n" + element
        }

        return (title, body)
    }

    func convert(with diary: Diary) -> String {
        return String(format: NameSpace.combineFormat, diary.title, diary.body)
    }
}

extension DiaryContentManager {
    private enum NameSpace {
        static let combineFormat = "%@\n%@"
        static let splitFormat = "\n"
    }
}
