//
//  File.swift
//  CustomCodable
//
//  Created by kerim njuhovic on 19. 2. 2026..
//

import Foundation
import SwiftCompilerPlugin
import SwiftSyntaxMacros

@main
struct CustomCodablePlugin: CompilerPlugin {
    let providingMacros: [Macro.Type] = [
        CustomCodableMacro.self,
        CodingKeyMacro.self,
    ]
}
