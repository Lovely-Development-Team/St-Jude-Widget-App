//
//  SearchBar.swift
//  St Jude
//
//  Created by Ben Cardy on 26/05/2021.
//

import SwiftUI
import UIKit


struct SearchBar: UIViewRepresentable {

    @Binding var text: String
    var placeholder: String
    @Binding var showingMyself: Bool

    class Coordinator: NSObject, UISearchBarDelegate {

        @Binding var text: String
        @Binding var showingMyself: Bool

        init(text: Binding<String>, showingMyself: Binding<Bool>) {
            _text = text
            _showingMyself = showingMyself
        }

        func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
            text = searchText
        }

        func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
            searchBar.showsCancelButton = true
        }
        
        func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
            searchBar.showsCancelButton = false
        }
        
        func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
            searchBar.resignFirstResponder()
            withAnimation {
                text = ""
                showingMyself = false
            }
        }
        
    }

    func makeCoordinator() -> SearchBar.Coordinator {
        return Coordinator(text: $text, showingMyself: $showingMyself)
    }

    func makeUIView(context: UIViewRepresentableContext<SearchBar>) -> UISearchBar {
        let searchBar = UISearchBar(frame: .zero)
        searchBar.delegate = context.coordinator
        searchBar.placeholder = placeholder
        searchBar.searchBarStyle = .minimal
        searchBar.becomeFirstResponder()
        searchBar.setImage(UIImage(systemName: "magnifyingglass"), for: .search, state: .normal)
//        searchBar.searchTextField.font = UIFont(name: Font.customFontName, size: UIFont.preferredFont(forTextStyle: .body).pointSize)
        return searchBar
    }

    func updateUIView(_ uiView: UISearchBar, context: UIViewRepresentableContext<SearchBar>) {
        uiView.text = text
    }
    
}

struct SearchBar_Previews: PreviewProvider {
    static var previews: some View {
        SearchBar(text: .constant("Search"), placeholder: "Search", showingMyself: .constant(true))
    }
}
