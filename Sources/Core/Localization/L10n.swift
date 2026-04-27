import Foundation

enum L10n {
    private static func tr(_ key: String) -> String {
        let value = NSLocalizedString(key, tableName: nil, bundle: .main, comment: "")
#if DEBUG
        if value == key {
            assertionFailure("Missing localization for key: \(key)")
        }
#endif
        return value
    }

    private static func fmt(_ key: String, _ args: CVarArg...) -> String {
        String(format: tr(key), locale: Locale.current, arguments: args)
    }

    // MARK: - App / Common

    static let appName = tr("app.name")

    static let commonEmail = tr("common.email")
    static let commonPassword = tr("common.password")
    static let commonCategory = tr("common.category")
    static let commonTitle = tr("common.title")
    static let commonCancel = tr("common.cancel")
    static let commonClose = tr("common.close")
    static let commonDone = tr("common.done")
    static let commonBack = tr("common.back")
    static let commonOk = tr("common.ok")
    static let commonCreateAnother = tr("common.create_another")
    static let commonContinueUppercase = tr("common.continue.uppercase")
    static let commonSendUppercase = tr("common.send.uppercase")
    static let commonBullet = tr("common.bullet")
    static let commonUser = tr("common.user")
    static let commonDelete = tr("common.delete")
    static let commonReviewedToday = tr("common.reviewed_today")
    static let commonTotal = tr("common.total")

    // MARK: - Tabs

    static let tabToday = tr("tabs.today")
    static let tabExplore = tr("tabs.explore")
    static let tabCreate = tr("tabs.create")
    static let tabAgility = tr("tabs.agility")
    static let tabChallenges = tr("tabs.challenges")
    static let tabLeaderboard = tr("tabs.leaderboard")
    static let leaderboardTitle = tr("leaderboard.title")
    static let tabModerator = tr("tabs.moderator")
    static let moderatorPanelTitle = tr("moderator.panel_title")
    static let moderatorExercisesHeader = tr("moderator.exercises_header")
    static let moderatorDetailTitle = tr("moderator.detail_title")
    static let moderatorApprove = tr("moderator.approve")
    static let moderatorReject = tr("moderator.reject")
    static func moderatorConfirmMsg(_ exercise: String) -> String {
        fmt("moderator.confirm_msg", exercise)
    }
    static let tabProfile = tr("tabs.profile")

    // MARK: - Auth Views

    static let authTagline = tr("auth.tagline")
    static let authSignIn = tr("auth.sign_in")
    static let authForgotPassword = tr("auth.forgot_password")
    static let authOr = tr("auth.or")
    static let authCreateAccount = tr("auth.create_account")

    static let authRegisterTitle = tr("auth.register.title")
    static let authRegisterNavTitle = tr("auth.register.nav_title")
    static let authRegisterSubtitle = tr("auth.register.subtitle")
    static let authNameLabel = tr("auth.name.label")
    static let authNamePlaceholder = tr("auth.name.placeholder")
    static let authEmailPlaceholder = tr("auth.email.placeholder")
    static let authUniversityLabel = tr("auth.university.label")
    static let authUniversityPlaceholder = tr("auth.university.placeholder")
    static let authPasswordPlaceholder = tr("auth.password.placeholder")
    static let authConfirmPasswordLabel = tr("auth.confirm_password.label")
    static let authConfirmPasswordPlaceholder = tr("auth.confirm_password.placeholder")

    static let authForgotTitle = tr("auth.forgot.title")
    static let authForgotHeading = tr("auth.forgot.heading")
    static let authForgotDescription = tr("auth.forgot.description")
    static let authForgotEmailPlaceholder = tr("auth.forgot.email.placeholder")
    static let authForgotSendLink = tr("auth.forgot.send_link")
    static let authForgotSuccessTitle = tr("auth.forgot.success.title")
    static func authForgotSuccessBody(_ email: String) -> String {
        fmt("auth.forgot.success.body", email)
    }
    static let authForgotBackToLogin = tr("auth.forgot.back_to_login")

    // MARK: - Auth Messages

    static let authValidationEmailRequired = tr("auth.validation.email_required")
    static let authValidationEmailInvalid = tr("auth.validation.email_invalid")
    static let authValidationPasswordRequired = tr("auth.validation.password_required")
    static let authValidationNameRequired = tr("auth.validation.name_required")
    static let authValidationPasswordLength = tr("auth.validation.password_length")
    static let authValidationPasswordMismatch = tr("auth.validation.password_mismatch")
    static let authRegisterSuccess = tr("auth.register.success")
    static func authResetSentTo(_ email: String) -> String {
        fmt("auth.reset.sent_to", email)
    }

    static let authDemoError = tr("auth.demo.error")
    static let authDemoUsername = tr("auth.demo.username")
    static let authDemoDisplayName = tr("auth.demo.display_name")
    static let authDemoUniversity = tr("auth.demo.university")

    // MARK: - Home / Landing

    static let homeLandingDescription = tr("home.landing.description")

    static let homeFeatureSpacedReviewTitle = tr("home.feature.spaced_review.title")
    static let homeFeatureSpacedReviewDescription = tr("home.feature.spaced_review.description")
    static let homeFeatureStreakTitle = tr("home.feature.streak.title")
    static let homeFeatureStreakDescription = tr("home.feature.streak.description")
    static let homeFeatureCommunityTitle = tr("home.feature.community.title")
    static let homeFeatureCommunityDescription = tr("home.feature.community.description")
    static let homeFeatureAgilityTitle = tr("home.feature.agility.title")
    static let homeFeatureAgilityDescription = tr("home.feature.agility.description")
    static let homeCreateAccountFree = tr("home.create_account.free")

    static func homeGreeting(_ name: String) -> String {
        fmt("home.greeting", name)
    }
    static let homeDailyCardsSubtitle = tr("home.daily_cards.subtitle")
    static let homePending = tr("home.pending")
    static let homeStartQuiz = tr("home.start_quiz")
    static func homePendingCards(_ count: Int) -> String {
        fmt("home.pending_cards", count)
    }
    static let homeMyFlashcards = tr("home.my_flashcards")
    static let homeNew = tr("home.new")
    static let homeNoFlashcards = tr("home.no_flashcards")
    static let homeCreateFirstFlashcard = tr("home.create_first_flashcard")
    static let homeCreateFlashcardCta = tr("home.create_flashcard.cta")
    static let homeDue = tr("home.due")
    static func homeNextReview(_ date: String) -> String {
        fmt("home.next_review", date)
    }

    // MARK: - Flashcard Quiz

    static func quizProgress(_ current: Int, _ total: Int) -> String {
        fmt("quiz.progress", current, total)
    }
    static func quizCorrectCount(_ count: Int) -> String {
        fmt("quiz.correct_count", count)
    }
    static let quizTitle = tr("quiz.title")
    static let quizExit = tr("quiz.exit")
    static let quizFinishedTitle = tr("quiz.finished.title")
    static func quizScore(_ correct: Int, _ total: Int) -> String {
        fmt("quiz.score", correct, total)
    }
    static let quizCorrectAnswers = tr("quiz.correct_answers")
    static func quizPercentage(_ value: Int) -> String {
        fmt("quiz.percentage", value)
    }
    static let quizBack = tr("quiz.back")
    static let quizResultTitle = tr("quiz.result.title")

    // MARK: - Create Flashcard

    static let flashcardCategorySection = tr("flashcard.create.section.category")
    static let flashcardQuestionSection = tr("flashcard.create.section.question")
    static let flashcardQuestionPlaceholder = tr("flashcard.create.question.placeholder")
    static let flashcardCorrectAnswerHeader = tr("flashcard.create.correct_answer.header")
    static let flashcardCorrectAnswerPlaceholder = tr("flashcard.create.correct_answer.placeholder")
    static let flashcardWrongAnswersHeader = tr("flashcard.create.wrong_answers.header")
    static let flashcardWrongOption1 = tr("flashcard.create.wrong_option_1")
    static let flashcardWrongOption2 = tr("flashcard.create.wrong_option_2")
    static let flashcardWrongOption3 = tr("flashcard.create.wrong_option_3")
    static let flashcardSave = tr("flashcard.create.save")
    static let flashcardNewTitle = tr("flashcard.create.title")
    static let flashcardSavedTitle = tr("flashcard.create.saved.title")
    static let flashcardSavedMessage = tr("flashcard.create.saved.message")

    // MARK: - Agility

    static func agilityLevel(_ level: Int) -> String {
        fmt("agility.level", level)
    }
    static func agilityProgress(_ count: Int) -> String {
        fmt("agility.progress", count)
    }
    static func agilityAnswer(_ answer: Int) -> String {
        fmt("agility.answer", answer)
    }
    static let agilityCorrect = tr("agility.correct")
    static let agilityTitle = tr("agility.title")

    // MARK: - Community

    static let communityAll = tr("community.all")
    static let communityNoExercises = tr("community.no_exercises")
    static let communityCreateFirstExercise = tr("community.create_first_exercise")
    static let communityViewExample = tr("community.view_example")
    static let communityExploreTitle = tr("community.explore.title")
    static let communitySearchPrompt = tr("community.search.prompt")

    static let communityCreateInfoSection = tr("community.create.info_section")
    static let communityCreateStatement = tr("community.create.statement")
    static let communityCreateSolution = tr("community.create.solution")
    static let communityPublish = tr("community.create.publish")
    static let communityPublishFooter = tr("community.create.footer")
    static let communityCreateTitle = tr("community.create.title")
    static let communityPublishedTitle = tr("community.create.published.title")
    static let communityPublishedMessage = tr("community.create.published.message")

    static let communityDetailTitle = tr("community.detail.title")
    static func communityDetailId(_ id: String) -> String {
        fmt("community.detail.id", id)
    }
    static let communityDetailPlaceholder = tr("community.detail.placeholder")
    static let communityExerciseTitle = tr("community.exercise.title")

    // MARK: - Challenges

    static let challengesTitle = tr("challenges.title")
    static let challengesSubtitle = tr("challenges.subtitle")
    static let challengesEnterLobby = tr("challenges.enter_lobby")

    static let duelLobbySection = tr("challenges.duel_lobby.section")
    static let duelLobbyFlowEnabled = tr("challenges.duel_lobby.flow_enabled")
    static let duelLobbyDescription = tr("challenges.duel_lobby.description")

    // MARK: - Profile

    static func profilePoints(_ points: Int) -> String {
        fmt("profile.points", points)
    }
    static func profileStreakDays(_ days: Int) -> String {
        fmt("profile.streak_days", days)
    }

    static let profilePointsTitle = tr("profile.stats.points")
    static let profileStreakTitle = tr("profile.stats.streak")
    static let profileLevelTitle = tr("profile.stats.level")
    static let profileLevelFallback = tr("profile.stats.level_fallback")

    static let profileEdit = tr("profile.menu.edit")
    static let profileBadges = tr("profile.menu.badges")
    static let profileStats = tr("profile.menu.stats")
    static let profileModeratorPanel = tr("profile.menu.moderator")
    static let profileSignOut = tr("profile.menu.sign_out")
    static let profileDeleteAccount = tr("profile.menu.delete_account")
    static let profileTitle = tr("profile.title")
    static let profileDeleteAlertTitle = tr("profile.delete.alert.title")
    static let profileDeleteAlertMessage = tr("profile.delete.alert.message")

    static let profileEditPlaceholder = tr("profile.edit.placeholder")
    static let profileBadgesPlaceholder = tr("profile.badges.placeholder")
    static let profileStatsPlaceholder = tr("profile.stats.placeholder")
    static let profileModeratorPlaceholder = tr("profile.moderator.placeholder")
    static let profileModeratorTitle = tr("profile.moderator.title")

    // MARK: - Notifications

    static let notificationTitle = tr("notification.title")
    static func notificationDueCards(_ dueCount: Int) -> String {
        fmt("notification.due_cards", dueCount)
    }
    static let notificationDailyReminder = tr("notification.daily_reminder")

    // MARK: - Constants display names

    static let categoryTrig = tr("category.trigonometry")
    static let categoryCalcDiff = tr("category.calculus_differential")
    static let categoryCalcInt = tr("category.calculus_integral")
    static let categoryDiffEq = tr("category.differential_equations")
    static let categoryLinearAlgebra = tr("category.linear_algebra")
    static let categoryProbability = tr("category.probability")

    static let exerciseStatusPending = tr("exercise.status.pending")
    static let exerciseStatusVerified = tr("exercise.status.verified")
    static let exerciseStatusRejected = tr("exercise.status.rejected")
    static let exerciseStatusArchived = tr("exercise.status.archived")

    static let userLevelNovice = tr("user.level.novice")
    static let userLevelStudent = tr("user.level.student")
    static let userLevelTutor = tr("user.level.tutor")
    static let userLevelMaster = tr("user.level.master")

    static let badgeFirstFlashcard = tr("badge.first_flashcard")
    static let badgeTenVerified = tr("badge.ten_verified")
    static let badgeSevenDayStreak = tr("badge.seven_day_streak")
    static let badgeHundredReviews = tr("badge.hundred_reviews")
    static let badgeTopVotedMonth = tr("badge.top_voted_month")

    static let reviewQualityDifficult = tr("review.quality.difficult")
    static let reviewQualityNormal = tr("review.quality.normal")
    static let reviewQualityEasy = tr("review.quality.easy")

    // MARK: - Sample data visible to users

    static let sampleQuestion1 = tr("sample.q1.question")
    static let sampleQuestion1Correct = tr("sample.q1.correct")
    static let sampleQuestion1Wrong1 = tr("sample.q1.wrong1")
    static let sampleQuestion1Wrong2 = tr("sample.q1.wrong2")
    static let sampleQuestion1Wrong3 = tr("sample.q1.wrong3")

    static let sampleQuestion2 = tr("sample.q2.question")
    static let sampleQuestion2Correct = tr("sample.q2.correct")
    static let sampleQuestion2Wrong1 = tr("sample.q2.wrong1")
    static let sampleQuestion2Wrong2 = tr("sample.q2.wrong2")
    static let sampleQuestion2Wrong3 = tr("sample.q2.wrong3")

    static let sampleQuestion3 = tr("sample.q3.question")
    static let sampleQuestion3Correct = tr("sample.q3.correct")
    static let sampleQuestion3Wrong1 = tr("sample.q3.wrong1")
    static let sampleQuestion3Wrong2 = tr("sample.q3.wrong2")
    static let sampleQuestion3Wrong3 = tr("sample.q3.wrong3")

    static let sampleQuestion4 = tr("sample.q4.question")
    static let sampleQuestion4Correct = tr("sample.q4.correct")
    static let sampleQuestion4Wrong1 = tr("sample.q4.wrong1")
    static let sampleQuestion4Wrong2 = tr("sample.q4.wrong2")
    static let sampleQuestion4Wrong3 = tr("sample.q4.wrong3")

    static let sampleQuestion5 = tr("sample.q5.question")
    static let sampleQuestion5Correct = tr("sample.q5.correct")
    static let sampleQuestion5Wrong1 = tr("sample.q5.wrong1")
    static let sampleQuestion5Wrong2 = tr("sample.q5.wrong2")
    static let sampleQuestion5Wrong3 = tr("sample.q5.wrong3")
}
