
import UIKit

class NoticeTableViewCell: UITableViewCell {

    let titleLabel = UILabel()
    let subtitleLabel = UILabel()
    let bulletPointsLabel = UILabel()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        contentView.backgroundColor = UIColor(hex: "#F1F4F8")
        
        titleLabel.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(titleLabel)

        subtitleLabel.font = UIFont.systemFont(ofSize: 14, weight: .light)
        subtitleLabel.textColor = .gray
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(subtitleLabel)

        bulletPointsLabel.numberOfLines = 0
        bulletPointsLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(bulletPointsLabel)

        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 24),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24),

            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            subtitleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            subtitleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24),

            bulletPointsLabel.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: 24),
            bulletPointsLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            bulletPointsLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24),
            bulletPointsLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -24)
        ])
    }

    func configure(with detail: Detail) {
        titleLabel.text = detail.title
        subtitleLabel.text = detail.subtitle

        let attributedText = NSMutableAttributedString()
        if let contents = detail.contents {
            for content in contents {
                let bulletPoint = createBulletPoint()
                let bulletItemText = NSAttributedString(string: " \(content)\n", attributes: [
                    .font: UIFont.systemFont(ofSize: 14, weight: .light),
                    .paragraphStyle: createParagraphStyle()
                ])
                attributedText.append(bulletPoint)
                attributedText.append(bulletItemText)
            }
        }
        bulletPointsLabel.attributedText = attributedText
    }

    private func createBulletPoint() -> NSAttributedString {
        let bulletPointAttachment = NSTextAttachment()
        let bulletSize: CGFloat = 6

        bulletPointAttachment.bounds = CGRect(x: 0, y: (UIFont.systemFont(ofSize: 14).capHeight - bulletSize) / 2, width: bulletSize, height: bulletSize)
        bulletPointAttachment.image = UIImage(systemName: "circle.fill")?.withTintColor(.black)
        
        return NSAttributedString(attachment: bulletPointAttachment)
    }

    private func createParagraphStyle() -> NSMutableParagraphStyle {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 8
        paragraphStyle.headIndent = 12 + 8
        
        return paragraphStyle
    }
}

