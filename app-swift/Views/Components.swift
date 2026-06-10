import SwiftUI

enum ClinicalPalette {
    static let background = Color(red: 0.96, green: 0.92, blue: 0.80)
    static let surface = Color(red: 1.00, green: 0.98, blue: 0.91)
    static let card = Color.white
    static let field = Color(red: 0.98, green: 0.94, blue: 0.83)
    static let darkGreen = Color(red: 0.15, green: 0.30, blue: 0.10)
    static let green = Color(red: 0.27, green: 0.47, blue: 0.19)
    static let lightGreen = Color(red: 0.75, green: 0.95, blue: 0.60)
    static let mutedGreen = Color(red: 0.58, green: 0.70, blue: 0.44)
    static let ink = Color(red: 0.18, green: 0.20, blue: 0.15)
    static let mutedInk = Color(red: 0.55, green: 0.55, blue: 0.47)
    static let warning = Color(red: 0.94, green: 0.74, blue: 0.22)
    static let blush = Color(red: 0.98, green: 0.80, blue: 0.82)
    static let blue = Color(red: 0.15, green: 0.39, blue: 0.52)
}

struct ClinicalCard<Content: View>: View {
    var padding: CGFloat = 14
    var background: Color = ClinicalPalette.card
    @ViewBuilder var content: Content

    var body: some View {
        content
            .padding(padding)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(background, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .stroke(.white.opacity(0.75), lineWidth: 1)
            }
            .shadow(color: ClinicalPalette.darkGreen.opacity(0.07), radius: 16, y: 8)
    }
}

struct EmptyState: View {
    let title: String
    let detail: String
    let icon: String

    var body: some View {
        VStack(spacing: 14) {
            Image(systemName: icon)
                .font(.system(size: 36, weight: .semibold))
                .foregroundStyle(ClinicalPalette.green)
                .frame(width: 76, height: 76)
                .background(ClinicalPalette.lightGreen.opacity(0.42), in: Circle())
            Text(title)
                .font(.headline)
                .foregroundStyle(ClinicalPalette.ink)
            Text(detail)
                .font(.subheadline)
                .multilineTextAlignment(.center)
                .foregroundStyle(ClinicalPalette.mutedInk)
        }
        .padding(28)
        .frame(maxWidth: .infinity)
        .background(ClinicalPalette.surface, in: RoundedRectangle(cornerRadius: 24, style: .continuous))
        .padding()
    }
}

struct MetricCard: View {
    let title: String
    let value: Int
    let icon: String
    let color: Color

    var body: some View {
        ClinicalCard(background: color) {
            VStack(alignment: .leading, spacing: 10) {
                Image(systemName: icon)
                    .font(.headline)
                    .foregroundStyle(.white.opacity(0.92))
                Text("\(value)")
                    .font(.system(size: 30, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                Text(title)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.white.opacity(0.82))
            }
            .frame(minHeight: 92, alignment: .leading)
        }
    }
}

struct ScreenBackground<Content: View>: View {
    @ViewBuilder var content: Content

    var body: some View {
        ZStack {
            ClinicalPalette.background.ignoresSafeArea()
            content
        }
    }
}

struct LeafBadge: View {
    var size: CGFloat = 58

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: size * 0.28, style: .continuous)
                .fill(ClinicalPalette.green)
            Image(systemName: "leaf.fill")
                .font(.system(size: size * 0.42, weight: .bold))
                .foregroundStyle(ClinicalPalette.lightGreen)
        }
        .frame(width: size, height: size)
        .shadow(color: ClinicalPalette.darkGreen.opacity(0.16), radius: 12, y: 8)
    }
}

struct AppHeader: View {
    let eyebrow: String
    let title: String
    var subtitle: String?
    var trailingSystemImage: String?
    var trailingAction: (() -> Void)?

    var body: some View {
        HStack(alignment: .center, spacing: 14) {
            VStack(alignment: .leading, spacing: 4) {
                Text(eyebrow)
                    .font(.caption.weight(.bold))
                    .textCase(.uppercase)
                    .foregroundStyle(ClinicalPalette.mutedInk)
                Text(title)
                    .font(.title2.weight(.bold))
                    .foregroundStyle(ClinicalPalette.ink)
                if let subtitle {
                    Text(subtitle)
                        .font(.subheadline)
                        .foregroundStyle(ClinicalPalette.mutedInk)
                }
            }
            Spacer()
            if let trailingSystemImage, let trailingAction {
                Button(action: trailingAction) {
                    Image(systemName: trailingSystemImage)
                        .font(.headline)
                        .foregroundStyle(ClinicalPalette.darkGreen)
                        .frame(width: 38, height: 38)
                        .background(ClinicalPalette.lightGreen, in: RoundedRectangle(cornerRadius: 12))
                }
            }
        }
    }
}

struct SearchPill: View {
    let text: String

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: "magnifyingglass")
            Text(text)
            Spacer()
        }
        .font(.caption.weight(.medium))
        .foregroundStyle(ClinicalPalette.mutedInk)
        .padding(.horizontal, 12)
        .frame(height: 36)
        .background(.white, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
    }
}

struct StatusChip: View {
    let title: String
    var color: Color = ClinicalPalette.lightGreen

    var body: some View {
        Text(title)
            .font(.caption2.weight(.bold))
            .foregroundStyle(ClinicalPalette.darkGreen)
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(color, in: Capsule())
    }
}

struct PrimaryActionButton: View {
    let title: String
    var systemImage: String?
    var isDisabled = false
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                if let systemImage {
                    Image(systemName: systemImage)
                }
                Text(title)
                    .fontWeight(.bold)
            }
            .font(.subheadline)
            .frame(maxWidth: .infinity)
            .frame(height: 48)
            .foregroundStyle(.white)
            .background(isDisabled ? ClinicalPalette.mutedInk.opacity(0.35) : ClinicalPalette.darkGreen,
                        in: RoundedRectangle(cornerRadius: 12, style: .continuous))
        }
        .disabled(isDisabled)
    }
}

struct ClinicalTextField: View {
    let title: String
    @Binding var text: String
    var axis: Axis = .horizontal
    var keyboardType: UIKeyboardType = .default

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.caption2.weight(.bold))
                .textCase(.uppercase)
                .foregroundStyle(ClinicalPalette.mutedInk)
            TextField(title, text: $text, axis: axis)
                .keyboardType(keyboardType)
                .textInputAutocapitalization(keyboardType == .emailAddress ? .never : .sentences)
                .padding(.horizontal, 12)
                .padding(.vertical, 12)
                .background(ClinicalPalette.field, in: RoundedRectangle(cornerRadius: 10, style: .continuous))
                .foregroundStyle(ClinicalPalette.ink)
        }
    }
}

struct ClinicalSecureField: View {
    let title: String
    @Binding var text: String

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.caption2.weight(.bold))
                .textCase(.uppercase)
                .foregroundStyle(ClinicalPalette.mutedInk)
            SecureField(title, text: $text)
                .padding(.horizontal, 12)
                .padding(.vertical, 12)
                .background(ClinicalPalette.field, in: RoundedRectangle(cornerRadius: 10, style: .continuous))
                .foregroundStyle(ClinicalPalette.ink)
        }
    }
}

struct FormSectionCard<Content: View>: View {
    let title: String
    @ViewBuilder var content: Content

    var body: some View {
        ClinicalCard(background: ClinicalPalette.surface) {
            VStack(alignment: .leading, spacing: 14) {
                Text(title)
                    .font(.caption.weight(.bold))
                    .textCase(.uppercase)
                    .foregroundStyle(ClinicalPalette.green)
                content
            }
        }
    }
}

struct ClinicalDatePicker: View {
    let title: String
    @Binding var selection: Date
    var components: DatePickerComponents = .date

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.caption2.weight(.bold))
                .textCase(.uppercase)
                .foregroundStyle(ClinicalPalette.mutedInk)
            DatePicker(title, selection: $selection, displayedComponents: components)
                .labelsHidden()
                .tint(ClinicalPalette.darkGreen)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 12)
                .padding(.vertical, 10)
                .background(ClinicalPalette.field, in: RoundedRectangle(cornerRadius: 10, style: .continuous))
        }
    }
}

extension View {
    func formSheetStyle() -> some View {
        self
            .scrollContentBackground(.hidden)
            .background(ClinicalPalette.background)
    }
}
