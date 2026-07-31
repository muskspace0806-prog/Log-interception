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
    private let mockCheckButton = UIButton(type: .system)
    private let mockReceiveButton = UIButton(type: .system)

    var onMockReceive: ((WebSocketMessage) -> Void)?
    private var message: WebSocketMessage?
    private var isMockSelected = false
    private var contentLeadingConstraints: [NSLayoutConstraint] = []
    private var contentTrailingConstraints: [NSLayoutConstraint] = []

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
        urlLabel.numberOfLines = 0
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

        mockCheckButton.tintColor = .systemRed
        mockCheckButton.layer.borderWidth = 2
        mockCheckButton.layer.borderColor = UIColor.systemRed.cgColor
        mockCheckButton.layer.cornerRadius = 2
        mockCheckButton.addTarget(self, action: #selector(mockReceiveTapped), for: .touchUpInside)
        mockCheckButton.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(mockCheckButton)

        configureMockReceiveButton(selected: false)
        mockReceiveButton.addTarget(self, action: #selector(mockReceiveTapped), for: .touchUpInside)
        mockReceiveButton.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(mockReceiveButton)

        let typeLeading = typeLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16)
        let urlLeading = urlLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16)
        let dataLeading = dataLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16)
        let sizeTrailing = sizeLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16)
        let urlTrailing = urlLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16)
        let dataTrailing = dataLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16)
        contentLeadingConstraints = [typeLeading, urlLeading, dataLeading]
        contentTrailingConstraints = [sizeTrailing, urlTrailing, dataTrailing]

        NSLayoutConstraint.activate([
            typeLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            typeLeading,

            timeLabel.centerYAnchor.constraint(equalTo: typeLabel.centerYAnchor),
            timeLabel.leadingAnchor.constraint(equalTo: typeLabel.trailingAnchor, constant: 8),
            timeLabel.trailingAnchor.constraint(lessThanOrEqualTo: mockCheckButton.leadingAnchor, constant: -8),

            mockCheckButton.centerYAnchor.constraint(equalTo: typeLabel.centerYAnchor),
            mockCheckButton.trailingAnchor.constraint(equalTo: mockReceiveButton.leadingAnchor, constant: -4),
            mockCheckButton.widthAnchor.constraint(equalToConstant: 22),
            mockCheckButton.heightAnchor.constraint(equalToConstant: 22),

            mockReceiveButton.centerYAnchor.constraint(equalTo: typeLabel.centerYAnchor),
            mockReceiveButton.trailingAnchor.constraint(lessThanOrEqualTo: sizeLabel.leadingAnchor, constant: -8),
            mockReceiveButton.heightAnchor.constraint(equalToConstant: 26),

            sizeLabel.centerYAnchor.constraint(equalTo: typeLabel.centerYAnchor),
            sizeTrailing,

            urlLabel.topAnchor.constraint(equalTo: typeLabel.bottomAnchor, constant: 6),
            urlLeading,
            urlTrailing,

            dataLabel.topAnchor.constraint(equalTo: urlLabel.bottomAnchor, constant: 4),
            dataLeading,
            dataTrailing,
            dataLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12)
        ])
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        message = nil
        onMockReceive = nil
        isMockSelected = false
        urlLabel.attributedText = nil
        dataLabel.attributedText = nil
        accessoryView = nil
        updateContentInsets(isCompact: false)
        mockCheckButton.isHidden = true
        mockReceiveButton.isHidden = true
        configureMockReceiveButton(selected: false)
    }

    func configure(with message: WebSocketMessage, isMockSelected: Bool = false, showsMockActions: Bool = true) {
        self.message = message
        self.isMockSelected = isMockSelected
        let isSampleMode = !showsMockActions
        updateContentInsets(isCompact: isSampleMode)
        typeLabel.text = "\(message.type.emoji) \(message.type.rawValue)"
        timeLabel.text = message.timeString
        dataLabel.attributedText = nil
        dataLabel.numberOfLines = isSampleMode ? 0 : 2
        if let route = message.route {
            urlLabel.attributedText = routeAttributedText(route: route, message: message)
        } else {
            urlLabel.attributedText = nil
            urlLabel.text = message.host
        }
        sizeLabel.text = message.dataSize
        let canMockReceive = showsMockActions && message.type == .receive
        mockCheckButton.isHidden = !canMockReceive
        mockReceiveButton.isHidden = !canMockReceive
        configureMockReceiveButton(selected: isMockSelected)
        updateMockCheckButton(selected: isMockSelected)

        switch message.type {
        case .connect:
            typeLabel.textColor = .systemGreen
            applyPlainURLColorIfNeeded(.label)
            dataLabel.textColor = .secondaryLabel
            dataLabel.text = "WebSocket 连接已建立"
        case .disconnect:
            typeLabel.textColor = .systemGray
            applyPlainURLColorIfNeeded(.label)
            dataLabel.textColor = .secondaryLabel
            dataLabel.text = message.dataString
        case .send:
            typeLabel.textColor = .systemBlue
            applyPlainURLColorIfNeeded(.label)
            dataLabel.textColor = .secondaryLabel
            dataLabel.text = message.dataPreview
        case .receive:
            typeLabel.textColor = .systemOrange
            applyPlainURLColorIfNeeded(.label)
            dataLabel.textColor = .secondaryLabel
            dataLabel.text = message.dataPreview
        case .error:
            typeLabel.textColor = .systemRed
            applyPlainURLColorIfNeeded(.systemRed)  // 错误时 URL 显示为红色
            dataLabel.textColor = .systemRed  // 错误信息也显示为红色
            dataLabel.text = message.dataString
        }

        if isSampleMode {
            dataLabel.attributedText = giftInfoAttributedText(fields: message.giftInfoFields)
        }
    }

    private func applyPlainURLColorIfNeeded(_ color: UIColor) {
        guard urlLabel.attributedText == nil else { return }
        urlLabel.textColor = color
    }

    private func updateContentInsets(isCompact: Bool) {
        let leading: CGFloat = isCompact ? 0 : 16
        let trailing: CGFloat = isCompact ? 0 : -16
        contentLeadingConstraints.forEach { $0.constant = leading }
        contentTrailingConstraints.forEach { $0.constant = trailing }
    }

    @objc private func mockReceiveTapped() {
        guard let message = message else { return }
        onMockReceive?(message)
    }

    private func configureMockReceiveButton(selected: Bool) {
        let backgroundColor: UIColor = selected ? .systemRed : .systemOrange
        if #available(iOS 15.0, *) {
            var title = AttributedString("模拟接收")
            title.font = .systemFont(ofSize: 13, weight: .semibold)
            var configuration = UIButton.Configuration.filled()
            configuration.attributedTitle = title
            configuration.baseForegroundColor = .white
            configuration.baseBackgroundColor = backgroundColor
            configuration.contentInsets = NSDirectionalEdgeInsets(top: 4, leading: 8, bottom: 4, trailing: 8)
            configuration.cornerStyle = .small
            mockReceiveButton.configuration = configuration
        } else {
            mockReceiveButton.setTitle("模拟接收", for: .normal)
            mockReceiveButton.titleLabel?.font = .systemFont(ofSize: 13, weight: .semibold)
            mockReceiveButton.setTitleColor(.white, for: .normal)
            mockReceiveButton.backgroundColor = backgroundColor
            mockReceiveButton.layer.cornerRadius = 4
            mockReceiveButton.contentEdgeInsets = UIEdgeInsets(top: 4, left: 8, bottom: 4, right: 8)
        }
    }

    private func updateMockCheckButton(selected: Bool) {
        if selected {
            if #available(iOS 13.0, *) {
                mockCheckButton.setImage(UIImage(systemName: "checkmark"), for: .normal)
            } else {
                mockCheckButton.setTitle("✓", for: .normal)
            }
        } else {
            mockCheckButton.setImage(nil, for: .normal)
            mockCheckButton.setTitle(nil, for: .normal)
        }
    }

    private func routeAttributedText(route: String, message: WebSocketMessage) -> NSAttributedString {
        let attributedText = NSMutableAttributedString(
            string: "Route: \(route)",
            attributes: [
                .font: UIFont.systemFont(ofSize: 15, weight: .semibold),
                .foregroundColor: UIColor.label
            ]
        )

        let firstSecond = message.firstSecond
        appendNormal("\n(first/second：", to: attributedText)
        appendValue(firstSecond.first ?? "nil", to: attributedText)
        appendNormal(" / ", to: attributedText)
        appendValue(firstSecond.second ?? "nil", to: attributedText)
        appendNormal(")", to: attributedText)

        return attributedText
    }

    private func giftInfoAttributedText(fields: [(name: String, value: String?)]) -> NSAttributedString {
        let text = NSMutableAttributedString()
        let valueMap = Dictionary(uniqueKeysWithValues: fields.map { ($0.name, $0.value ?? "nil") })
        appendNormal("giftName: ", to: text)
        appendValue(valueMap["giftName"] ?? "nil", to: text)
        appendNormal("\n", to: text)
        appendNormal("giftId: ", to: text)
        appendValue(valueMap["giftId"] ?? "nil", to: text)
        appendNormal("    giftNum: ", to: text)
        appendValue(valueMap["giftNum"] ?? "nil", to: text)
        appendNormal("    giftType: ", to: text)
        appendValue(valueMap["giftType"] ?? "nil", to: text)
        appendNormal("\n", to: text)
        appendNormal("isWholeMic: ", to: text)
        appendValue(valueMap["isWholeMic"] ?? "nil", to: text)
        appendNormal("    comboCount: ", to: text)
        appendValue(valueMap["comboCount"] ?? "nil", to: text)
        return text
    }

    private func appendNormal(_ string: String, to text: NSMutableAttributedString) {
        text.append(NSAttributedString(
            string: string,
            attributes: [
                .font: UIFont.systemFont(ofSize: 13, weight: .medium),
                .foregroundColor: UIColor.label
            ]
        ))
    }

    private func appendValue(_ string: String, to text: NSMutableAttributedString) {
        text.append(NSAttributedString(
            string: string,
            attributes: [
                .font: UIFont.systemFont(ofSize: 13, weight: .semibold),
                .foregroundColor: UIColor.systemPurple
            ]
        ))
    }
}
