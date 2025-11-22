import SwiftUI

struct MainTabView: View {
    // Customizing Tab Bar Appearance
    init() {
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor.black.withAlphaComponent(0.8)
        
        // Selected Item Color
        appearance.stackedLayoutAppearance.selected.iconColor = UIColor.white
        appearance.stackedLayoutAppearance.selected.titleTextAttributes = [.foregroundColor: UIColor.white]
        
        // Unselected Item Color
        appearance.stackedLayoutAppearance.normal.iconColor = UIColor.gray
        appearance.stackedLayoutAppearance.normal.titleTextAttributes = [.foregroundColor: UIColor.gray]
        
        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
    }
    
    var body: some View {
        TabView {
            HebrewView()
                .tabItem {
                    Label("Hebrew", systemImage: "character.book.closed.fill")
                }
            
            ArabicView()
                .tabItem {
                    Label("Arabic", systemImage: "text.book.closed.fill") // Distinct icon
                }
            
            HardEnglishView()
                .tabItem {
                    Label("English", systemImage: "textformat.abc")
                }
        }
        .accentColor(.white)
    }
}

struct MainTabView_Previews: PreviewProvider {
    static var previews: some View {
        MainTabView()
    }
}
