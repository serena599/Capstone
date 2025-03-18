import SwiftUI

struct MenuRow: View {
    let title: String
    let icon: String
    var fontSize: CGFloat = 14

    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.black)
                .frame(width: 25)

            Text(title)
                .font(.system(size: fontSize))
                .foregroundColor(.black)

            Spacer()

            Image(systemName: "chevron.right")
                .foregroundColor(.foodGray)
                .font(.system(size: 14))
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 15)
    }
}
