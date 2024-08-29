

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
        titleLabel.text = "注意事項"
        titleLabel.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(titleLabel)
        
        subtitleLabel.text = "優惠活動注意事項、活動辦法"
        subtitleLabel.font = UIFont.systemFont(ofSize: 14, weight: .light)
        subtitleLabel.textColor = .gray
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(subtitleLabel)
        
        let bulletText = """
        產品頁面上顯示的金額可能會因匯率和季節而波動。實際金額以預訂時的付款金額為準。
        KKday保留更改或終止促銷的權利恕不另行通知。
        由於天氣或其他原因，我們可能會取消您預訂的產品或旅遊。在這種情況下，我們的客戶中心將與您聯繫。
        如果您對優惠內容有任何疑問或問題，請通過右側聯繫方式與我們聯繫。聯繫方式：service@kkday.com
        """
        
        let attributedText = NSMutableAttributedString()
        
        // Split the text by new lines to create individual bullet points
        let bulletPoints = bulletText.split(separator: "\n")
        for bullet in bulletPoints {
            let bulletPoint = createBulletPoint()
            let bulletItemText = NSAttributedString(string: " \(bullet)\n", attributes: [
                .font: UIFont.systemFont(ofSize: 14, weight: .light),
                .paragraphStyle: createParagraphStyle()
            ])
            
            attributedText.append(bulletPoint)
            attributedText.append(bulletItemText)
        }
        
        bulletPointsLabel.attributedText = attributedText
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
    
    private func createBulletPoint() -> NSAttributedString {
        let bulletPointAttachment = NSTextAttachment()
        let bulletSize: CGFloat = 6 // Adjust the size of the bullet point here
        bulletPointAttachment.bounds = CGRect(x: 0, y: (UIFont.systemFont(ofSize: 14).capHeight - bulletSize) / 2, width: bulletSize, height: bulletSize)
        bulletPointAttachment.image = UIImage(systemName: "circle.fill")?.withTintColor(.black)
        
        return NSAttributedString(attachment: bulletPointAttachment)
    }
    
    private func createParagraphStyle() -> NSMutableParagraphStyle {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 8
        paragraphStyle.headIndent = 12 + 8 // Indent to make room for bullet and a space
        return paragraphStyle
    }
}

