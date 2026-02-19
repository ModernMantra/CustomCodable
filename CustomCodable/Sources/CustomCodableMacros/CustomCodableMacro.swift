import SwiftSyntax
import SwiftSyntaxMacros

// MARK: - @CodingKey (peer macro — marker only)

public struct CodingKeyMacro: PeerMacro {
    public static func expansion(
        of node: AttributeSyntax,
        providingPeersOf declaration: some DeclSyntaxProtocol,
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        // Emits nothing — CustomCodableMacro reads this attribute directly
        return []
    }
}

// MARK: - @CustomCodable (member macro)

public struct CustomCodableMacro: MemberMacro {
    public static func expansion(
        of node: AttributeSyntax,
        providingMembersOf declaration: some DeclGroupSyntax,
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {

        let members = declaration.memberBlock.members
        var caseDecls: [String] = []
        var initParams: [String] = []
        var initAssignments: [String] = []

        for member in members {
            guard let varDecl = member.decl.as(VariableDeclSyntax.self),
                  let binding = varDecl.bindings.first,
                  let pattern = binding.pattern.as(IdentifierPatternSyntax.self),
                  let typeAnnotation = binding.typeAnnotation
            else { continue }

            let propName = pattern.identifier.text
            let propType = typeAnnotation.type.trimmedDescription

            // Build CodingKeys case
            if let attr = varDecl.attributes.first(where: {
                $0.as(AttributeSyntax.self)?.attributeName
                    .as(IdentifierTypeSyntax.self)?.name.text == "CodingKey"
            }),
               let attrSyntax = attr.as(AttributeSyntax.self),
               let args = attrSyntax.arguments?.as(LabeledExprListSyntax.self),
               let firstArg = args.first,
               let stringLiteral = firstArg.expression.as(StringLiteralExprSyntax.self),
               let key = stringLiteral.segments.first?.as(StringSegmentSyntax.self)?.content.text
            {
                caseDecls.append("case \(propName) = \"\(key)\"")
            } else {
                caseDecls.append("case \(propName)")
            }

            // Build init parameter and assignment
            initParams.append("\(propName): \(propType)")
            initAssignments.append("self.\(propName) = \(propName)")
        }

        let casesSource = caseDecls.joined(separator: "\n        ")
        let paramsSource = initParams.joined(separator: ", ")
        let assignSource = initAssignments.joined(separator: "\n        ")

        let codingKeys: DeclSyntax = """
        enum CodingKeys: String, CodingKey {
            \(raw: casesSource)
        }
        """

        let initializer: DeclSyntax = """
        init(\(raw: paramsSource)) {
            \(raw: assignSource)
        }
        """

        return [codingKeys, initializer]
    }
}
