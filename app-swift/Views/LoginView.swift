import SwiftUI

struct LoginView: View {
    @EnvironmentObject private var session: SessionViewModel

    var body: some View {
        ScreenBackground {
            VStack(spacing: 22) {
                Spacer(minLength: 24)

                VStack(spacing: 16) {
                    Capsule()
                        .fill(.black)
                        .frame(width: 54, height: 9)
                        .padding(.bottom, 4)

                    LeafBadge(size: 62)

                    VStack(spacing: 4) {
                        Text("NutriCare Pro")
                            .font(.system(size: 32, weight: .bold, design: .rounded))
                            .foregroundStyle(ClinicalPalette.darkGreen)
                        Text("Gestion clinica nutricional")
                            .font(.subheadline.weight(.medium))
                            .foregroundStyle(ClinicalPalette.mutedInk)
                    }
                }

                ClinicalCard(padding: 18, background: ClinicalPalette.surface) {
                    VStack(spacing: 14) {
                        ClinicalTextField(title: "Correo electronico", text: $session.email, keyboardType: .emailAddress)
                            .textContentType(.emailAddress)
                        ClinicalSecureField(title: "Contrasena", text: $session.password)
                            .textContentType(.password)

                        if let error = session.errorMessage {
                            Text(error)
                                .font(.footnote.weight(.semibold))
                                .foregroundStyle(.red)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.top, 2)
                        }

                        PrimaryActionButton(
                            title: session.isLoading ? "Entrando..." : "Iniciar sesion",
                            systemImage: session.isLoading ? nil : "arrow.right",
                            isDisabled: session.isLoading || session.email.isEmpty || session.password.isEmpty
                        ) {
                            Task { await session.login() }
                        }
                        .padding(.top, 4)
                    }
                }

                Text("Acceso inicial: admin@nutricarepro.com / admin123")
                    .font(.caption)
                    .foregroundStyle(ClinicalPalette.mutedInk)

                Spacer()

                Text("Diseno inspirado en consulta clinica nutricional")
                    .font(.caption2.weight(.semibold))
                    .foregroundStyle(ClinicalPalette.green)
            }
            .padding(28)
        }
    }
}
