//
//  EmptyView.swift
//  SimpleMovieSearch
//
//  Created by Jinyoung Kim on 2022/12/19.
//

import UIKit

final class EmptyView: UIView {
    let title: String
    
    init(title: String) {
        self.title = title
        super.init(frame: .zero)
        configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configure() {
        backgroundColor = .white
        let label = UILabel()
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 30)
        label.text = title
        label.textColor = .black
        
        addSubview(label)
        
        label.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }
}
