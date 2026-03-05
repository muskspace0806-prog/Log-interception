//
//  NetworkLogCell.swift
//  日志拦截工具
//
//  网络日志列表单元格
//

import UIKit

class NetworkLogCell: UITableViewCell {
    
    private let methodLabel = UILabel()
    private let statusCodeLabel = UILabel()
    private let urlLabel = UILabel()
    private let timeLabel = UILabel()
    private let durationLabel = UILabel()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }
    
    private func setupUI() {
        // Method 标签
        methodLabel.font = .systemFont(ofSize: 12, weight: .bold)
        methodLabel.textColor = .white
        methodLabel.textAlignment = .center
        methodLabel.layer.cornerRadius = 4
        methodLabel.layer.masksToBounds = true
        methodLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(methodLabel)
        
        // 状态码标签
        statusCodeLabel.font = .systemFont(ofSize: 14, weight: .semibold)
        statusCodeLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(statusCodeLabel)
        
        // URL 标签
        urlLabel.font = .systemFont(ofSize: 14)
        urlLabel.numberOfLines = 2
        urlLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(urlLabel)
        
        // 时间标签
        timeLabel.font = .systemFont(ofSize: 12)
        timeLabel.textColor = .secondaryLabel
        timeLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(timeLabel)
        
        // 耗时标签
        durationLabel.font = .systemFont(ofSize: 12, weight: .medium)
        durationLabel.textColor = .systemGreen
        durationLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(durationLabel)
        
        // 布局
        NSLayoutConstraint.activate([
            methodLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
            methodLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            methodLabel.widthAnchor.constraint(equalToConstant: 50),
            methodLabel.heightAnchor.constraint(equalToConstant: 22),
            
            statusCodeLabel.leadingAnchor.constraint(equalTo: methodLabel.trailingAnchor, constant: 8),
            statusCodeLabel.centerYAnchor.constraint(equalTo: methodLabel.centerYAnchor),
            
            urlLabel.leadingAnchor.constraint(equalTo: methodLabel.leadingAnchor),
            urlLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12),
            urlLabel.topAnchor.constraint(equalTo: methodLabel.bottomAnchor, constant: 8),
            
            timeLabel.leadingAnchor.constraint(equalTo: methodLabel.leadingAnchor),
            timeLabel.topAnchor.constraint(equalTo: urlLabel.bottomAnchor, constant: 6),
            timeLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12),
            
            durationLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12),
            durationLabel.centerYAnchor.constraint(equalTo: timeLabel.centerYAnchor)
        ])
    }
    
    func configure(with request: InterceptedRequest) {
        // Method
        methodLabel.text = request.method
        switch request.method {
        case "GET":
            methodLabel.backgroundColor = .systemBlue
        case "POST":
            methodLabel.backgroundColor = .systemGreen
        case "PUT":
            methodLabel.backgroundColor = .systemOrange
        case "DELETE":
            methodLabel.backgroundColor = .systemRed
        default:
            methodLabel.backgroundColor = .systemGray
        }
        
        // 状态码
        if let statusCode = request.statusCode {
            statusCodeLabel.text = "\(statusCode)"
            switch statusCode {
            case 200..<300:
                statusCodeLabel.textColor = .systemGreen
            case 300..<400:
                statusCodeLabel.textColor = .systemOrange
            case 400..<500:
                statusCodeLabel.textColor = .systemRed
            case 500..<600:
                statusCodeLabel.textColor = .systemPurple
            default:
                statusCodeLabel.textColor = .systemGray
            }
        } else if request.error != nil {
            statusCodeLabel.text = "❌"
            statusCodeLabel.textColor = .systemRed
        } else {
            statusCodeLabel.text = "⏳"
            statusCodeLabel.textColor = .systemGray
        }
        
        // URL - 失败的请求显示为红色
        urlLabel.text = request.url
        if request.error != nil || (request.statusCode != nil && request.statusCode! >= 400) {
            urlLabel.textColor = .systemRed
        } else {
            urlLabel.textColor = .label
        }
        
        // 时间
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss.SSS"
        timeLabel.text = formatter.string(from: request.startTime)
        
        // 耗时
        if let duration = request.duration {
            durationLabel.text = String(format: "%.0fms", duration * 1000)
            
            // 根据耗时设置颜色
            if duration < 0.5 {
                durationLabel.textColor = .systemGreen
            } else if duration < 2.0 {
                durationLabel.textColor = .systemOrange
            } else {
                durationLabel.textColor = .systemRed
            }
        } else {
            durationLabel.text = "-"
            durationLabel.textColor = .systemGray
        }
    }
}
