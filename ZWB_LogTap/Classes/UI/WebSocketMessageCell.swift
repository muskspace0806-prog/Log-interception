//
//  WebSocketMessageCell.swift
//  日志拦截工具
//
//  WebSocket 消息列表单元格
//

import UIKit

class WebSocketMessageCell: UITableViewCell {
    
    private let typeLabel = UILabel()
    private let timeLabel = UILabel()
    private let urlLabel = UILabel()
    private let dataLabel = UILabel()
    private let sizeLabel = UILabel()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        // 类型标签
        typeLabel.font = .systemFont(ofSize: 16, weight: .bold)
        typeLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(typeLabel)
        
        // 时间标签
        timeLabel.font = .systemFont(ofSize: 12)
        timeLabel.textColor = .secondaryLabel
        timeLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(timeLabel)
        
        // URL/Route 标签
        urlLabel.font = .systemFont(ofSize: 15, weight: .semibold)
        urlLabel.textColor = .label
        urlLabel.numberOfLines = 1
        urlLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(urlLabel)
        
        // 数据标签
        dataLabel.font = .systemFont(ofSize: 13)
        dataLabel.textColor = .secondaryLabel
        dataLabel.numberOfLines = 2
        dataLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(dataLabel)
        
        // 大小标签
        sizeLabel.font = .systemFont(ofSize: 12)
        sizeLabel.textColor = .tertiaryLabel
        sizeLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(sizeLabel)
        
        NSLayoutConstraint.activate([
            typeLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            typeLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            
            timeLabel.centerYAnchor.constraint(equalTo: typeLabel.centerYAnchor),
            timeLabel.leadingAnchor.constraint(equalTo: typeLabel.trailingAnchor, constant: 8),
            
            sizeLabel.centerYAnchor.constraint(equalTo: typeLabel.centerYAnchor),
            sizeLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            urlLabel.topAnchor.constraint(equalTo: typeLabel.bottomAnchor, constant: 6),
            urlLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            urlLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            dataLabel.topAnchor.constraint(equalTo: urlLabel.bottomAnchor, constant: 4),
            dataLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            dataLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            dataLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12)
        ])
    }
    
    func configure(with message: WebSocketMessage) {
        typeLabel.text = "\(message.type.emoji) \(message.type.rawValue)"
        timeLabel.text = message.timeString
        if let route = message.route {
            urlLabel.text = "Route: \(route)"
        } else {
            urlLabel.text = message.host
        }
        sizeLabel.text = message.dataSize
        
        switch message.type {
        case .connect:
            typeLabel.textColor = .systemGreen
            urlLabel.textColor = .label
            dataLabel.textColor = .secondaryLabel
            dataLabel.text = "WebSocket 连接已建立"
        case .disconnect:
            typeLabel.textColor = .systemGray
            urlLabel.textColor = .label
            dataLabel.textColor = .secondaryLabel
            dataLabel.text = message.dataString
        case .send:
            typeLabel.textColor = .systemBlue
            urlLabel.textColor = .label
            dataLabel.textColor = .secondaryLabel
            dataLabel.text = message.dataPreview
        case .receive:
            typeLabel.textColor = .systemOrange
            urlLabel.textColor = .label
            dataLabel.textColor = .secondaryLabel
            dataLabel.text = message.dataPreview
        case .error:
            typeLabel.textColor = .systemRed
            urlLabel.textColor = .systemRed  // 错误时 URL 显示为红色
            dataLabel.textColor = .systemRed  // 错误信息也显示为红色
            dataLabel.text = message.dataString
        }
    }
}
