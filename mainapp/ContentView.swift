import SwiftUI
import AVFoundation

// MARK: - Design Tokens
struct DesignTokens {
    // Colors
    struct Colors {
        // 主色调（树懒绿）
        static let primary = Color(red: 0.290, green: 0.486, blue: 0.349)   // #4A7C59

        // 背景：奶油色 + 白
        static let backgroundPrimary = Color(red: 0.956, green: 0.941, blue: 0.910) // #F4F0E8
        static let backgroundSecondary = Color.white                                // #FFFFFF

        // 文本颜色：主黑、副灰
        static let textPrimary = Color(red: 0.1, green: 0.1, blue: 0.1)
        static let textSecondary = Color(red: 0.5, green: 0.5, blue: 0.5)

        // 边框：淡奶油灰
        static let border = Color(red: 0.878, green: 0.863, blue: 0.831) // #E0DCD4

        // 状态色：绿 & 红（保持自然）
        static let success = Color(red: 0.290, green: 0.486, blue: 0.349) // 同 primary
        static let error   = Color(red: 0.8, green: 0.3, blue: 0.3)

        // 渐变背景（由浅奶油到稍深）
        static let discordGradientTop = Color(red: 0.956, green: 0.941, blue: 0.910) // #F4F0E8
        static let discordGradientBottom = Color(red: 0.769, green: 0.706, blue: 0.643) // #C4B4A4

        // 面板：白卡片
        static let discordPanel = Color.white
        static let discordPanelBorder = Color(red: 0.878, green: 0.863, blue: 0.831) // #E0DCD4

        // 输入框背景：更浅的奶油色
        static let discordInputBackground = Color(red: 0.922, green: 0.922, blue: 0.922) // #EBEBEB

        // 文本：主黑 + 副灰
        static let discordTextPrimary = Color(red: 0.1, green: 0.1, blue: 0.1)
        static let discordTextSecondary = Color(red: 0.5, green: 0.5, blue: 0.5)

        // 强调色：树懒绿（用于按钮/链接）
        static let discordAccent = Color(red: 0.290, green: 0.486, blue: 0.349) // #4A7C59
    }

    // Typography
    struct Typography {
        static let title = Font.system(size: 24, weight: .semibold)
        static let body = Font.system(size: 16, weight: .regular)
        static let caption = Font.system(size: 13, weight: .regular)
    }

    // Spacing
    struct Spacing {
        static let padding: CGFloat = 16
        static let moduleSpacing: CGFloat = 20
        static let elementSpacing: CGFloat = 12
        static let smallSpacing: CGFloat = 8
    }

    // Corner Radius
    struct CornerRadius {
        static let card: CGFloat = 12
        static let button: CGFloat = 12
    }

    // Touch Target
    struct TouchTarget {
        static let minHeight: CGFloat = 44
        static let preferredHeight: CGFloat = 48
    }

    // Animation
    struct Animation {
        static let buttonPress = SwiftUI.Animation.easeInOut(duration: 0.1)
        static let cardFlip = SwiftUI.Animation.easeInOut(duration: 0.25)
        static let cardSwipe = SwiftUI.Animation.spring(
            response: 0.6,
            dampingFraction: 0.8,
            blendDuration: 0
        )
        static let cardDrag = SwiftUI.Animation.interactiveSpring(
            response: 0.4,
            dampingFraction: 0.8,
            blendDuration: 0
        )
    }
}

// MARK: - View Extensions
extension View {
    func cardStyle() -> some View {
        self
            .background(DesignTokens.Colors.backgroundSecondary)
            .cornerRadius(DesignTokens.CornerRadius.card)
            .shadow(color: DesignTokens.Colors.textPrimary.opacity(0.08), radius: 8, x: 0, y: 2)
    }

    func containerPadding() -> some View {
        self.padding(.horizontal, DesignTokens.Spacing.padding)
    }
}

struct ContentView: View {
    @State private var username = ""
    @State private var password = ""
    @State private var isLoading = false
    @State private var alertMessage = ""
    @State private var isLoggedIn = true // false

    var body: some View {
        Group {
            if isLoggedIn {
                //VocabularyLearningView()
                SoundsView()
//                WelcomeView(username: username, onLogout: {
//                    isLoggedIn = false
//                    username = ""
//                    password = ""
//                })
            } else {
                DiscordLoginView(
                    username: $username,
                    password: $password,
                    alertMessage: $alertMessage,
                    isLoading: $isLoading,
                    isFormValid: isFormValid,
                    onForgotPassword: {
                        alertMessage = "密码重置功能即将推出！"
                    },
                    onRegister: {
                        alertMessage = "注册功能即将推出！"
                    },
                    onLogin: login
                )
            }
        }
        .animation(.easeInOut(duration: 0.3), value: isLoggedIn)
    }

    private var isFormValid: Bool {
        !username.trimmingCharacters(in: .whitespaces).isEmpty &&
        !password.isEmpty &&
        password.count >= 6
    }

    private func login() {
        alertMessage = ""
        isLoading = true

        // Simulate network delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            isLoading = false

            // Simple validation
            let trimmedUsername = username.trimmingCharacters(in: .whitespaces)

            if trimmedUsername.isEmpty {
                alertMessage = "请输入用户名"
            } else if password.isEmpty {
                alertMessage = "请输入密码"
            } else if password.count < 6 {
                alertMessage = "密码至少需要6个字符"
            } else if trimmedUsername.lowercased() == "admin" && password == "password123" {
                // Successful login
                isLoggedIn = true
                alertMessage = ""
            } else {
                alertMessage = "用户名或密码无效。请尝试 'admin' / 'password123'"
            }
        }
    }
}

struct DiscordLoginView: View {
    @Binding var username: String
    @Binding var password: String
    @Binding var alertMessage: String
    @Binding var isLoading: Bool
    let isFormValid: Bool
    let onForgotPassword: () -> Void
    let onRegister: () -> Void
    let onLogin: () -> Void

    var body: some View {
        GeometryReader { geometry in
            let isCompact = geometry.size.width < 700

            ZStack {
                Image("LoginImage")              // 你的图片名（放在 Assets.xcassets 里）
                    .resizable()
                    //.scaledToFill()           // 填满
                    .ignoresSafeArea()        // 延伸到状态栏/底部安全区
                ScrollView(showsIndicators: false) {
                    VStack {
                        //Spacer(minLength: isCompact ? 40 : 80)
                        Spacer(minLength: isCompact ? 40 : 80)
                        Group {
                            if isCompact {
                                VStack(spacing: 24) {
                                    loginSection
                                }
                            } else {
                                HStack(alignment: .top, spacing: 32) {
                                    loginSection
                                        .frame(maxWidth: 420)
                                }
                            }
                        }
                        .padding(isCompact ? 24 : 32)
                        .background(DesignTokens.Colors.discordPanel)
                        .cornerRadius(24)
                        .overlay(
                            RoundedRectangle(cornerRadius: 24)
                                .stroke(DesignTokens.Colors.discordPanelBorder, lineWidth: 1)
                        )
                        .padding(.horizontal, isCompact ? 24 : 0)
                        .frame(maxWidth: min(geometry.size.width * 0.92, 820))

                        Spacer(minLength: isCompact ? 40 : 80)
                    }
                    .frame(width: geometry.size.width, height: geometry.size.height)
                }
            }
        }
    }

    @ViewBuilder
    private var loginSection: some View {
        VStack(alignment: .leading, spacing: 20) {

            VStack(alignment: .leading, spacing: 18) {
                field(
                    title: "电子邮件 / 手机号",
                    placeholder: "输入电子邮件、手机号或用户名",
                    text: $username
                )

                field(
                    title: "密码",
                    placeholder: "请输入密码",
                    text: $password,
                    isSecure: true
                )
            }

            if !alertMessage.isEmpty {
                Text(alertMessage)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(DesignTokens.Colors.error)
            }

            Button(action: onLogin) {
                HStack(spacing: 12) {
                    if isLoading {
                        ProgressView()
                            .scaleEffect(0.85)
                            .tint(.white)
                    }
                    Text(isLoading ? "登录中..." : "登录")
                        .font(.system(size: 16, weight: .semibold))
                }
                .frame(maxWidth: .infinity)
                .frame(height: DesignTokens.TouchTarget.preferredHeight)
                .background(DesignTokens.Colors.discordAccent.opacity(isFormValid ? 1.0 : 0.4))
                .foregroundColor(.white)
                .cornerRadius(12)
            }
            .disabled(!isFormValid || isLoading)
            .opacity(!isFormValid || isLoading ? 0.85 : 1.0)

            Button("忘记密码？", action: onForgotPassword)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(DesignTokens.Colors.discordAccent)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.top, 4)

            Divider()
                .overlay(DesignTokens.Colors.discordPanelBorder)
                .padding(.vertical, 4)

            HStack(spacing: 4) {
                Text("还没有账户？")
                    .font(.system(size: 14))
                    .foregroundColor(DesignTokens.Colors.discordTextSecondary)

                Button("注册", action: onRegister)
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(DesignTokens.Colors.discordAccent)
            }
        }
    }

    @ViewBuilder
    private func field(title: String, placeholder: String, text: Binding<String>, isSecure: Bool = false) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title.uppercased())
                .font(.system(size: 12, weight: .bold))
                .foregroundColor(DesignTokens.Colors.discordTextSecondary)

            Group {
                if isSecure {
                    SecureField(placeholder, text: text)
                        .textContentType(.password)
                        .textFieldStyle(CustomTextFieldStyle())
                } else {
                    TextField(placeholder, text: text)
                        .textContentType(.username)
                        .textFieldStyle(CustomTextFieldStyle())
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled(true)
                }
            }
        }
    }

}

struct CustomTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .font(.system(size: 16))
            .foregroundColor(DesignTokens.Colors.discordTextPrimary)
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .frame(minHeight: DesignTokens.TouchTarget.minHeight)
            .background(DesignTokens.Colors.discordInputBackground)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(DesignTokens.Colors.discordPanelBorder, lineWidth: 1)
            )
            .tint(DesignTokens.Colors.discordAccent)
    }
}

struct WelcomeView: View {
    let username: String
    let onLogout: () -> Void
    @State private var showVocabularyView = false

    var body: some View {
        ZStack {
            DesignTokens.Colors.backgroundPrimary
                .ignoresSafeArea()

            VStack(spacing: DesignTokens.Spacing.moduleSpacing) {
                Spacer()

                VStack(spacing: DesignTokens.Spacing.elementSpacing) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 64))
                        .foregroundColor(DesignTokens.Colors.success)

                    Text("欢迎，\(username)！")
                        .font(DesignTokens.Typography.title)
                        .foregroundColor(DesignTokens.Colors.textPrimary)

                    Text("您已成功登录")
                        .font(DesignTokens.Typography.body)
                        .foregroundColor(DesignTokens.Colors.textSecondary)
                }

                VStack(spacing: DesignTokens.Spacing.elementSpacing) {
                    Button("背单词") {
                        showVocabularyView = true
                    }
                    .buttonStyle(PrimaryButtonStyle())

                    Button("看新闻") {
                        // Profile action
                    }
                    .buttonStyle(SecondaryButtonStyle())
                    
                    Button("社交网络") {
                        // Profile action
                    }
                    .buttonStyle(SecondaryButtonStyle())

                    Button("查看资料") {
                        // Profile action
                    }
                    .buttonStyle(SecondaryButtonStyle())

                    Button("设置") {
                        // Settings action
                    }
                    .buttonStyle(SecondaryButtonStyle())

                    Button("退出登录") {
                        onLogout()
                    }
                    .buttonStyle(SecondaryButtonStyle())
                }
                .containerPadding()

                Spacer()
            }
            .containerPadding()
        }
        .fullScreenCover(isPresented: $showVocabularyView) {
            VocabularyLearningView()
        }
    }
}

struct PrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(DesignTokens.Typography.body.weight(.semibold))
            .frame(maxWidth: .infinity)
            .frame(height: DesignTokens.TouchTarget.preferredHeight)
            .background(DesignTokens.Colors.primary)
            .foregroundColor(.white)
            .cornerRadius(DesignTokens.CornerRadius.button)
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .animation(DesignTokens.Animation.buttonPress, value: configuration.isPressed)
    }
}

struct SecondaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(DesignTokens.Typography.body.weight(.medium))
            .frame(maxWidth: .infinity)
            .frame(height: DesignTokens.TouchTarget.preferredHeight)
            .background(DesignTokens.Colors.backgroundSecondary)
            .foregroundColor(DesignTokens.Colors.textPrimary)
            .cornerRadius(DesignTokens.CornerRadius.button)
            .overlay(
                RoundedRectangle(cornerRadius: DesignTokens.CornerRadius.button)
                    .stroke(DesignTokens.Colors.border, lineWidth: 1)
            )
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .animation(DesignTokens.Animation.buttonPress, value: configuration.isPressed)
    }
}

// MARK: - Vocabulary Learning Models
struct VocabularyCard: Identifiable {
    let id = UUID()
    let word: String
    let pronunciation: String
    let chineseMeaning: String
    let englishMeaning: String
    let example: String
    let quote: String
    let author: String
}

// MARK: - Sample Data
extension VocabularyCard {
    static let sampleCards = [
        VocabularyCard(
            word: "Apple",
            pronunciation: "/ˈæpəl/",
            chineseMeaning: "苹果",
            englishMeaning: "a round fruit with red or green skin",
            example: "I eat an **apple** every morning.",
            quote: "An **apple** a day keeps the doctor away.",
            author: "Welsh Proverb"
        ),
        VocabularyCard(
            word: "Book",
            pronunciation: "/bʊk/",
            chineseMeaning: "书",
            englishMeaning: "a set of printed pages fastened together",
            example: "She is reading a **book** about history.",
            quote: "A room without **books** is like a body without a soul.",
            author: "Cicero"
        ),
        VocabularyCard(
            word: "Computer",
            pronunciation: "/kəmˈpjuːtər/",
            chineseMeaning: "电脑",
            englishMeaning: "an electronic device for processing data",
            example: "My **computer** is running very slowly today.",
            quote: "The **computer** was born to solve problems that did not exist before.",
            author: "Bill Gates"
        ),
        VocabularyCard(
            word: "Beautiful",
            pronunciation: "/ˈbjuːtɪfəl/",
            chineseMeaning: "美丽的",
            englishMeaning: "having beauty; pleasing to look at",
            example: "The sunset looks absolutely **beautiful**.",
            quote: "The most **beautiful** things in the world cannot be seen or touched, they are felt with the heart.",
            author: "Helen Keller"
        ),
        VocabularyCard(
            word: "Learning",
            pronunciation: "/ˈlɜːrnɪŋ/",
            chineseMeaning: "学习",
            englishMeaning: "the process of acquiring knowledge",
            example: "**Learning** a new language takes time and practice.",
            quote: "**Learning** never exhausts the mind.",
            author: "Leonardo da Vinci"
        )
    ]
}

// MARK: - Vocabulary Learning View
struct VocabularyLearningView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var currentCardIndex = 0
    @State private var isFlipped = false
    @State private var cards = VocabularyCard.sampleCards
    @State private var completedCards: [UUID] = []
    @State private var dragOffset: CGSize = .zero
    @State private var isSwipeInProgress = false
    @State private var cardScale: CGFloat = 1.0
    @State private var cardRotation: Double = 0
    @State private var isTransitioning = false

    var currentCard: VocabularyCard? {
        guard currentCardIndex < cards.count else { return nil }
        return cards[currentCardIndex]
    }

    var body: some View {
        ZStack {
            DesignTokens.Colors.backgroundPrimary
                .ignoresSafeArea()

            VStack(spacing: DesignTokens.Spacing.moduleSpacing) {
                // Header
                HStack {
                    Button("返回") {
                        dismiss()
                    }
                    .foregroundColor(DesignTokens.Colors.primary)
                    .font(DesignTokens.Typography.body)

                    Spacer()

                    Text("背单词")
                        .font(DesignTokens.Typography.title)
                        .foregroundColor(DesignTokens.Colors.textPrimary)

                    Spacer()

                    VStack(spacing: DesignTokens.Spacing.smallSpacing) {
                        Text("\(currentCardIndex + 1)/\(cards.count)")
                            .font(DesignTokens.Typography.body)
                            .foregroundColor(DesignTokens.Colors.textSecondary)

                        // Progress dots
                        HStack(spacing: 4) {
                            ForEach(0..<min(cards.count, 8), id: \.self) { index in
                                Circle()
                                    .fill(index == currentCardIndex ? DesignTokens.Colors.primary : DesignTokens.Colors.border)
                                    .frame(width: 6, height: 6)
                            }
                            if cards.count > 8 {
                                Text("...")
                                    .font(DesignTokens.Typography.caption)
                                    .foregroundColor(DesignTokens.Colors.textSecondary)
                            }
                        }
                    }
                }
                .containerPadding()
                .padding(.top, DesignTokens.Spacing.elementSpacing)

                // Swipe hints
                HStack {
                    if currentCardIndex > 0 {
                        HStack(spacing: DesignTokens.Spacing.smallSpacing) {
                            Image(systemName: "chevron.left")
                            Text("上一张")
                        }
                        .font(DesignTokens.Typography.caption)
                        .foregroundColor(DesignTokens.Colors.textSecondary)
                        .opacity(dragOffset.width > 50 ? 1.0 : 0.3)
                    }

                    Spacer()

                    if currentCardIndex < cards.count - 1 {
                        HStack(spacing: DesignTokens.Spacing.smallSpacing) {
                            Text("下一张")
                            Image(systemName: "chevron.right")
                        }
                        .font(DesignTokens.Typography.caption)
                        .foregroundColor(DesignTokens.Colors.textSecondary)
                        .opacity(dragOffset.width < -50 ? 1.0 : 0.3)
                    }
                }
                .containerPadding()
                .animation(.easeInOut(duration: 0.2), value: dragOffset.width)
                .animation(.easeInOut(duration: 0.2), value: isSwipeInProgress)

                // Learning Card with swipe navigation
                if let card = currentCard {
                    VStack(spacing: DesignTokens.Spacing.elementSpacing) {
                        // Card container
                        GeometryReader { geometry in
                            ZStack {
                                // Previous card (shown when swiping right)
                                if currentCardIndex > 0 && dragOffset.width > 0 {
                                    VocabularyCardView(
                                        card: cards[currentCardIndex - 1],
                                        isFlipped: .constant(false)
                                    )
                                    .offset(x: dragOffset.width - geometry.size.width * 0.8)
                                    .opacity(min(1.0, 0.3 + (dragOffset.width / geometry.size.width) * 0.7))
                                    .scaleEffect(0.95 + (dragOffset.width / geometry.size.width) * 0.05)
                                    .blur(radius: max(0, 3 - (dragOffset.width / geometry.size.width) * 3))
                                }

                                // Next card (shown when swiping left)
                                if currentCardIndex < cards.count - 1 && dragOffset.width < 0 {
                                    VocabularyCardView(
                                        card: cards[currentCardIndex + 1],
                                        isFlipped: .constant(false)
                                    )
                                    .offset(x: dragOffset.width + geometry.size.width * 0.8)
                                    .opacity(min(1.0, 0.3 + (abs(dragOffset.width) / geometry.size.width) * 0.7))
                                    .scaleEffect(0.95 + (abs(dragOffset.width) / geometry.size.width) * 0.05)
                                    .blur(radius: max(0, 3 - (abs(dragOffset.width) / geometry.size.width) * 3))
                                }

                                // Current card
                                VocabularyCardView(
                                    card: card,
                                    isFlipped: $isFlipped
                                )
                                .offset(x: calculateDragOffset(dragOffset.width, screenWidth: geometry.size.width))
                                .rotationEffect(.degrees(cardRotation))
                                .scaleEffect(cardScale)
                                .opacity(calculateCardOpacity(dragOffset.width, screenWidth: geometry.size.width))
                            }
                        }
                        .frame(height: 320)
                        .gesture(
                            DragGesture()
                                .onChanged { value in
                                    // 只有在非转换状态时才响应拖拽
                                    if !isTransitioning {
                                        updateDragAnimation(translation: value.translation)
                                    }
                                }
                                .onEnded { value in
                                    // 防止在转换过程中重复触发
                                    if !isTransitioning {
                                        handleSwipeGesture(translation: value.translation, velocity: value.velocity)
                                    }
                                }
                        )

                        // Quote section
                        QuoteView(card: card)
                            .containerPadding()
                    }
                } else {
                    // Completion view
                    VStack(spacing: DesignTokens.Spacing.elementSpacing) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 80))
                            .foregroundColor(DesignTokens.Colors.success)

                        Text("学习完成！")
                            .font(DesignTokens.Typography.title)
                            .foregroundColor(DesignTokens.Colors.textPrimary)

                        Text("恭喜完成本轮单词学习")
                            .font(DesignTokens.Typography.body)
                            .foregroundColor(DesignTokens.Colors.textSecondary)

                        Button("重新开始") {
                            resetLearning()
                        }
                        .buttonStyle(PrimaryButtonStyle())
                        .containerPadding()
                    }
                }

                Spacer()

                // Feedback Buttons (只在有卡片且已翻面时显示)
                if currentCard != nil && isFlipped {
                    VocabularyFeedbackButtons { difficulty in
                        handleFeedback(difficulty: difficulty)
                    }
                }
            }
        }
    }

    private func resetLearning() {
        currentCardIndex = 0
        isFlipped = false
        completedCards.removeAll()
        dragOffset = .zero
        isSwipeInProgress = false
        cardScale = 1.0
        cardRotation = 0
        isTransitioning = false
    }

    // MARK: - Animation Helper Functions
    private func updateDragAnimation(translation: CGSize) {
        // 移除动画以获得更直接的响应，只在必要时使用动画
        dragOffset = translation
        isSwipeInProgress = abs(translation.width) > 10 || abs(translation.height) > 10

        // Calculate rotation based on horizontal drag
        let maxRotation: Double = 8
        cardRotation = min(maxRotation, max(-maxRotation, Double(translation.width) / 20))

        // Calculate scale with subtle effect
        let maxDrag: CGFloat = 200
        let dragAmount = min(maxDrag, abs(translation.width))
        cardScale = 1.0 - (dragAmount / maxDrag) * 0.05
    }

    private func calculateDragOffset(_ dragWidth: CGFloat, screenWidth: CGFloat) -> CGFloat {
        let resistance: CGFloat = 0.8
        let maxDrag = screenWidth * 0.7

        // Apply resistance when dragging beyond certain threshold
        if abs(dragWidth) > maxDrag {
            let excess = abs(dragWidth) - maxDrag
            let resistedExcess = excess * resistance
            return dragWidth > 0 ? maxDrag + resistedExcess : -maxDrag - resistedExcess
        }

        return dragWidth
    }

    private func calculateCardOpacity(_ dragWidth: CGFloat, screenWidth: CGFloat) -> Double {
        let maxDrag = screenWidth * 0.5
        let dragRatio = min(1.0, abs(dragWidth) / maxDrag)
        return 1.0 - (dragRatio * 0.3)
    }

    private func handleSwipeGesture(translation: CGSize, velocity: CGSize) {
        let swipeThreshold: CGFloat = 80  // 降低距离阈值
        let velocityThreshold: CGFloat = 500  // 降低速度阈值
        let horizontalMovement: CGFloat = translation.width
        let verticalMovement: CGFloat = abs(translation.height)
        let horizontalVelocity: CGFloat = velocity.width

        // 计算垂直与水平的比例，如果垂直滑动过于明显则不处理
        let verticalRatio = verticalMovement / max(abs(horizontalMovement), 1)
        if verticalRatio > 1.5 {
            resetCardPosition()
            return
        }

        // 更灵敏的判断逻辑
        let canGoNext = currentCardIndex < cards.count - 1
        let canGoPrevious = currentCardIndex > 0

        let shouldSwipeLeft = canGoNext && (
            horizontalMovement < -swipeThreshold ||  // 距离足够
            (horizontalVelocity < -velocityThreshold && horizontalMovement < -20) ||  // 速度足够且有基本位移
            (abs(horizontalMovement) > 30 && horizontalVelocity < -300)  // 中等位移+中等速度
        )

        let shouldSwipeRight = canGoPrevious && (
            horizontalMovement > swipeThreshold ||  // 距离足够
            (horizontalVelocity > velocityThreshold && horizontalMovement > 20) ||  // 速度足够且有基本位移
            (abs(horizontalMovement) > 30 && horizontalVelocity > 300)  // 中等位移+中等速度
        )

        if shouldSwipeLeft {
            goToNextCard()
        } else if shouldSwipeRight {
            goToPreviousCard()
        } else {
            resetCardPosition()
        }
    }

    private func resetCardPosition() {
        guard !isTransitioning else { return }
        isTransitioning = true

        withAnimation(DesignTokens.Animation.cardSwipe) {
            dragOffset = .zero
            isSwipeInProgress = false
            cardScale = 1.0
            cardRotation = 0
        } completion: {
            isTransitioning = false
        }
    }

    private func goToNextCard() {
        guard !isTransitioning else { return }
        isTransitioning = true

        withAnimation(DesignTokens.Animation.cardSwipe) {
            if currentCardIndex < cards.count - 1 {
                currentCardIndex += 1
                isFlipped = false
            }
            dragOffset = .zero
            isSwipeInProgress = false
            cardScale = 1.0
            cardRotation = 0
        } completion: {
            isTransitioning = false
        }
    }

    private func goToPreviousCard() {
        guard !isTransitioning else { return }
        isTransitioning = true

        withAnimation(DesignTokens.Animation.cardSwipe) {
            if currentCardIndex > 0 {
                currentCardIndex -= 1
                isFlipped = false
            }
            dragOffset = .zero
            isSwipeInProgress = false
            cardScale = 1.0
            cardRotation = 0
        } completion: {
            isTransitioning = false
        }
    }

    private func handleFeedback(difficulty: FeedbackDifficulty) {
        guard let card = currentCard else { return }

        // 添加到已完成列表
        completedCards.append(card.id)

        // 根据难度决定是否重新加入学习队列
        switch difficulty {
        case .again:
            // 再来一次 - 将卡片移到队列末尾
            cards.append(cards.remove(at: currentCardIndex))
        case .hard, .good, .easy:
            // 其他情况 - 移到下一张卡片
            if currentCardIndex >= cards.count - 1 {
                // 如果是最后一张，完成学习
                currentCardIndex = cards.count
            } else {
                currentCardIndex += 1
            }
        }

        // 重置翻面状态
        isFlipped = false
    }
}

// MARK: - Vocabulary Card View
struct VocabularyCardView: View {
    let card: VocabularyCard
    @Binding var isFlipped: Bool

    var body: some View {
        ZStack {
            // Front Side (单词) - 显示当未翻转时
            CardFrontView(card: card)
                .opacity(isFlipped ? 0 : 1)
                .rotation3DEffect(
                    .degrees(isFlipped ? 90 : 0),
                    axis: (x: 0, y: 1, z: 0)
                )

            // Back Side (释义) - 显示当翻转时
            CardBackView(card: card)
                .opacity(isFlipped ? 1 : 0)
                .rotation3DEffect(
                    .degrees(isFlipped ? 0 : -90),
                    axis: (x: 0, y: 1, z: 0)
                )
        }
        .frame(maxWidth: .infinity)
        .frame(height: 280)
        .cardStyle()
        .containerPadding()
        .onTapGesture {
            withAnimation(DesignTokens.Animation.cardFlip) {
                isFlipped.toggle()
            }
        }
    }
}
// MARK: - SoundsView View
struct SoundsView: View {
    @StateObject private var playbackController = SoundPlaybackController(resourceName: "lessonSound")

    private let transcriptSegments = TranscriptSegment.lessonSample

    var body: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.elementSpacing) {
            VStack(alignment: .leading, spacing: DesignTokens.Spacing.smallSpacing) {
                HStack(spacing: DesignTokens.Spacing.smallSpacing) {
                    Button(action: playbackController.togglePlayback) {
                        Image(systemName: playbackController.isPlaying ? "pause.fill" : "play.fill")
                            .font(.system(size: 18, weight: .bold))
                            .frame(width: 44, height: 44)
                            .foregroundColor(.white)
                    }
                    .buttonStyle(PlaybackButtonStyle(isActive: playbackController.isPlaying))

                    ProgressView(value: playbackController.progress)
                        .progressViewStyle(.linear)
                        .tint(DesignTokens.Colors.primary)
                        .frame(maxWidth: .infinity)
                }

                HStack {
                    Text(formatTime(playbackController.currentTime))
                        .font(DesignTokens.Typography.caption.monospacedDigit())
                        .foregroundColor(DesignTokens.Colors.textSecondary)

                    Spacer()

                    Text(formatTime(playbackController.duration, placeholder: "--:--"))
                        .font(DesignTokens.Typography.caption.monospacedDigit())
                        .foregroundColor(DesignTokens.Colors.textSecondary)
                }
            }

            VStack(alignment: .leading, spacing: DesignTokens.Spacing.smallSpacing) {
                ForEach(transcriptSegments) { segment in
                    transcriptRow(for: segment)
                }
            }

            if let errorMessage = playbackController.errorMessage {
                Text(errorMessage)
                    .font(DesignTokens.Typography.caption)
                    .foregroundColor(DesignTokens.Colors.error)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.vertical, DesignTokens.Spacing.padding)
        .cardStyle()
        .containerPadding()
    }

    private func formatTime(_ time: TimeInterval, placeholder: String = "00:00") -> String {
        guard time.isFinite, !time.isNaN, time > 0 else { return placeholder }

        let totalSeconds = Int(time.rounded())
        let minutes = totalSeconds / 60
        let seconds = totalSeconds % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }

    @ViewBuilder
    private func transcriptRow(for segment: TranscriptSegment) -> some View {
        let isActive = segment.contains(playbackController.progress)

        Text(segment.text)
            .font(DesignTokens.Typography.body)
            .foregroundColor(isActive ? DesignTokens.Colors.primary : DesignTokens.Colors.textPrimary)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.vertical, 8)
            .padding(.horizontal, 12)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(isActive ? DesignTokens.Colors.primary.opacity(0.12) : Color.clear)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(isActive ? DesignTokens.Colors.primary.opacity(0.4) : DesignTokens.Colors.border, lineWidth: 1)
            )
            .animation(.easeInOut(duration: 0.2), value: isActive)
    }
}

private struct TranscriptSegment: Identifiable {
    let id = UUID()
    let text: String
    let range: ClosedRange<Double>

    func contains(_ progress: Double) -> Bool {
        guard !range.isEmpty else { return false }
        let clamped = max(0, min(progress, 1))
        if range.upperBound == 1 {
            return clamped >= range.lowerBound && clamped <= range.upperBound
        }
        return clamped >= range.lowerBound && clamped < range.upperBound
    }

    static let lessonSample: [TranscriptSegment] = [
        TranscriptSegment(
            text: "Welcome to today's listening warm-up. 你好，欢迎来到今天的听力热身。",
            range: 0.0...0.18
        ),
        TranscriptSegment(
            text: "Focus on the rhythm as you hear each phrase. 请留意每一句的节奏。",
            range: 0.18...0.38
        ),
        TranscriptSegment(
            text: "Repeat softly after the narrator to build confidence. 跟着朗读者轻声复述，建立自信。",
            range: 0.38...0.6
        ),
        TranscriptSegment(
            text: "Notice the linking sounds and intonation. 注意连读和语调的变化。",
            range: 0.6...0.82
        ),
        TranscriptSegment(
            text: "Great job! Take a breath and get ready for the next challenge. 做得很好！深呼吸，准备迎接下一个挑战。",
            range: 0.82...1.0
        )
    ]
}

private struct PlaybackButtonStyle: ButtonStyle {
    let isActive: Bool

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .background(isActive ? DesignTokens.Colors.primary.opacity(0.9) : DesignTokens.Colors.primary)
            .clipShape(Circle())
            .overlay(
                Circle()
                    .stroke(Color.white.opacity(configuration.isPressed ? 0.1 : 0.2), lineWidth: 1)
            )
            .scaleEffect(configuration.isPressed ? 0.94 : 1)
            .shadow(color: DesignTokens.Colors.primary.opacity(configuration.isPressed ? 0.08 : 0.2), radius: 8, x: 0, y: 4)
            .animation(DesignTokens.Animation.buttonPress, value: configuration.isPressed)
    }
}

final class SoundPlaybackController: NSObject, ObservableObject, AVAudioPlayerDelegate {
    @Published private(set) var isPlaying = false
    @Published var errorMessage: String?
    @Published private(set) var progress: Double = 0
    @Published private(set) var currentTime: TimeInterval = 0
    @Published private(set) var duration: TimeInterval = 0

    private let resourceName: String
    private let resourceExtension: String
    private var audioPlayer: AVAudioPlayer?
    private var progressTimer: Timer?

    init(resourceName: String, resourceExtension: String = "mp3") {
        self.resourceName = resourceName
        self.resourceExtension = resourceExtension
    }

    deinit {
        stopProgressUpdates()
    }

    func togglePlayback() {
        errorMessage = nil

        if isPlaying {
            pause()
        } else {
            play()
        }
    }

    private func play() {
        if audioPlayer == nil {
            configurePlayer()
        }

        guard let player = audioPlayer else {
            if errorMessage == nil {
                errorMessage = "音频资源缺失"
            }
            return
        }

        player.currentTime = 0
        player.play()
        isPlaying = true
        progress = 0
        currentTime = 0
        startProgressUpdates()
    }

    private func pause() {
        audioPlayer?.pause()
        updateProgress()
        stopProgressUpdates()
        isPlaying = false
    }

    private func configurePlayer() {
        guard let url = Bundle.main.url(forResource: resourceName, withExtension: resourceExtension) else {
            errorMessage = "未找到音频文件"
            progress = 0
            return
        }

        do {
            let player = try AVAudioPlayer(contentsOf: url)
            player.delegate = self
            player.prepareToPlay()
            audioPlayer = player
            progress = 0
            currentTime = 0
            duration = player.duration
        } catch {
            errorMessage = "无法加载音频"
            progress = 0
            currentTime = 0
            duration = 0
        }
    }

    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        stopProgressUpdates()
        progress = 1
        currentTime = duration
        isPlaying = false
    }

    private func startProgressUpdates() {
        stopProgressUpdates()

        let timer = Timer(timeInterval: 0.1, repeats: true) { [weak self] _ in
            self?.updateProgress()
        }

        RunLoop.main.add(timer, forMode: .common)
        timer.fire()
        progressTimer = timer
    }

    private func stopProgressUpdates() {
        progressTimer?.invalidate()
        progressTimer = nil
    }

    private func updateProgress() {
        guard let player = audioPlayer, player.duration > 0 else {
            progress = 0
            currentTime = 0
            duration = audioPlayer?.duration ?? 0
            return
        }

        progress = max(0, min(player.currentTime / player.duration, 1))
        currentTime = player.currentTime
        duration = player.duration
    }
}

// MARK: - Card Front View
struct CardFrontView: View {
    let card: VocabularyCard
    private let synthesizer = AVSpeechSynthesizer()
    var body: some View {
        VStack(spacing: DesignTokens.Spacing.elementSpacing) {
            Spacer()

            VStack(spacing: DesignTokens.Spacing.smallSpacing) {
                Text(card.word)
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(DesignTokens.Colors.textPrimary)

                Text(card.pronunciation)
                    .font(DesignTokens.Typography.body)
                    .foregroundColor(DesignTokens.Colors.textSecondary)
            }

            Spacer()

            HStack {
                Spacer()
                Button(action: {speak(text: card.word)}) {
                    Image(systemName: "speaker.wave.2")
                        .font(.system(size: 20))
                        .foregroundColor(DesignTokens.Colors.textSecondary)
                }
                .padding(.trailing, DesignTokens.Spacing.elementSpacing)
                .padding(.bottom, DesignTokens.Spacing.elementSpacing)
            }
            
        }
    }
    private func speak(text: String) {
        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice(language: "zh-CN") // 可以改成 "ja-JP" / "zh-CN"
        utterance.rate = 0.5
        synthesizer.speak(utterance)
    }
}

// MARK: - Card Back View
struct CardBackView: View {
    let card: VocabularyCard

    var body: some View {
        VStack(spacing: DesignTokens.Spacing.elementSpacing) {
            // 中文释义
            VStack(spacing: DesignTokens.Spacing.smallSpacing) {
                Text(card.word)
                    .font(DesignTokens.Typography.body.weight(.semibold))
                    .foregroundColor(DesignTokens.Colors.textSecondary)

                Text(card.chineseMeaning)
                    .font(DesignTokens.Typography.title)
                    .foregroundColor(DesignTokens.Colors.textPrimary)
            }

            Divider()
                .background(DesignTokens.Colors.border)

            // 英文释义
            Text(card.englishMeaning)
                .font(DesignTokens.Typography.body)
                .foregroundColor(DesignTokens.Colors.textSecondary)
                .multilineTextAlignment(.center)

            Divider()
                .background(DesignTokens.Colors.border)

            // 例句
            Text(card.example.replacingOccurrences(of: "**", with: ""))
                .font(DesignTokens.Typography.body)
                .foregroundColor(DesignTokens.Colors.textSecondary)
                .multilineTextAlignment(.center)
        }
        .padding(DesignTokens.Spacing.padding)
    }
}

// MARK: - Quote View
struct QuoteView: View {
    let card: VocabularyCard

    var body: some View {
        VStack(spacing: DesignTokens.Spacing.smallSpacing) {
            // Quote icon
            HStack {
                Image(systemName: "quote.opening")
                    .font(.system(size: 16))
                    .foregroundColor(DesignTokens.Colors.primary)
                Spacer()
            }

            // Quote text with highlighting
            VStack(alignment: .leading, spacing: DesignTokens.Spacing.smallSpacing) {
                HighlightedText(
                    text: card.quote,
                    highlightWord: card.word,
                    font: DesignTokens.Typography.body.italic(),
                    textColor: DesignTokens.Colors.textPrimary,
                    highlightColor: DesignTokens.Colors.primary
                )

                // Author attribution
                HStack {
                    Spacer()
                    Text("— \(card.author)")
                        .font(DesignTokens.Typography.caption)
                        .foregroundColor(DesignTokens.Colors.textSecondary)
                }
            }
        }
        .padding(DesignTokens.Spacing.elementSpacing)
        .background(
            RoundedRectangle(cornerRadius: DesignTokens.CornerRadius.card)
                .fill(DesignTokens.Colors.backgroundSecondary)
                .overlay(
                    RoundedRectangle(cornerRadius: DesignTokens.CornerRadius.card)
                        .stroke(DesignTokens.Colors.primary.opacity(0.2), lineWidth: 1)
                )
        )
    }
}

// MARK: - Highlighted Text Component
struct HighlightedText: View {
    let text: String
    let highlightWord: String
    let font: Font
    let textColor: Color
    let highlightColor: Color

    var body: some View {
        Text(attributedText)
            .font(font)
            .multilineTextAlignment(.leading)
            .lineSpacing(4)
    }

    private var attributedText: AttributedString {
        var attributed = AttributedString(cleanText)
        attributed.foregroundColor = textColor

        guard !highlightWord.isEmpty else {
            return attributed
        }

        var searchRange = cleanText.startIndex..<cleanText.endIndex
        while let range = cleanText.range(of: highlightWord, options: [.caseInsensitive], range: searchRange) {
            guard
                let lower = AttributedString.Index(range.lowerBound, within: attributed),
                let upper = AttributedString.Index(range.upperBound, within: attributed)
            else {
                break
            }

            let highlightRange = lower..<upper
            attributed[highlightRange].foregroundColor = .white
            attributed[highlightRange].backgroundColor = highlightColor

            searchRange = range.upperBound..<cleanText.endIndex
        }

        return attributed
    }

    private var cleanText: String {
        text.replacingOccurrences(of: "**", with: "")
    }
}

// MARK: - Feedback Buttons
enum FeedbackDifficulty {
    case again, hard, good, easy
}

struct VocabularyFeedbackButtons: View {
    let onFeedback: (FeedbackDifficulty) -> Void

    var body: some View {
        HStack(spacing: DesignTokens.Spacing.smallSpacing) {
            Button("再来") {
                onFeedback(.again)
            }
            .buttonStyle(FeedbackButtonStyle(color: DesignTokens.Colors.error))

            Button("困难") {
                onFeedback(.hard)
            }
            .buttonStyle(FeedbackButtonStyle(color: Color.orange))

            Button("模糊") {
                onFeedback(.good)
            }
            .buttonStyle(FeedbackButtonStyle(color: DesignTokens.Colors.primary))

            Button("熟悉") {
                onFeedback(.easy)
            }
            .buttonStyle(FeedbackButtonStyle(color: DesignTokens.Colors.success))
        }
        .containerPadding()
    }
}

struct FeedbackButtonStyle: ButtonStyle {
    let color: Color

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(DesignTokens.Typography.body.weight(.medium))
            .frame(maxWidth: .infinity)
            .frame(height: DesignTokens.TouchTarget.preferredHeight)
            .background(color)
            .foregroundColor(.white)
            .cornerRadius(DesignTokens.CornerRadius.button)
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .animation(DesignTokens.Animation.buttonPress, value: configuration.isPressed)
    }
}

#Preview {
    ContentView()
}

// Separate Preview for vocabulary learning
/*
#Preview {
    VocabularyLearningView()
}
*/
