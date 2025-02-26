import SwiftUI

struct CustomTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .padding(.horizontal, 10)
            .foregroundColor(.white)
            .accentColor(.white)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(.white.opacity(0.5), lineWidth: 1)
            )
            .tint(.white) // For cursor and selection
    }
} 