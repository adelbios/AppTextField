//
//  AppTextFeild.swift
//  Ra7ty
//
//  Created by Adel Radwan on 1/10/2021.
//

import UIKit

//MARK: - Placeholder ststus
private enum PlaceholderState {
    case top
    case middle
}

//MARK: - FeildStatus
private enum FeildStatus {
    case normal
    case active
    case error
}

//MARK: - Protocol
@objc protocol AppTextFeildDelegate: AnyObject {
    @objc optional dynamic func textFieldDidBeginEditing(_ textField: UITextField)
    @objc optional dynamic func textFieldDidEndEditing(_ textField: UITextField)
    @objc optional dynamic func didTextFieldClicked(_ textField: UITextField)
}

//MARK: - AppTextField
@IBDesignable
class AppTextFeild: UITextField {
    
    private var settings = Settings.shared
    
    private var placeHolderLabelLeadingAnchor: NSLayoutConstraint!
    
    private var placeholderStatus: PlaceholderState = .middle { didSet{ changePlaceholderPosition() } }
    
    private var feildStatus: FeildStatus = .normal { didSet{ changeFeildStatus() } }
    
    private var oldPlaceholder: String = ""
    
    private var hasErrorValidation = false
    
    private var isSecureText = false
    
    private lazy var padding = UIEdgeInsets(top: 20, left: 20, bottom: 0, right: 20)
    
    var placeholderBackgroundColor = AppColor.white.value
    
    weak var textFieldDelegate: AppTextFeildDelegate?
    
    @IBInspectable var makeTextFieldClcikable = false
    
    override var isSecureTextEntry: Bool{
        didSet {
            self.isSecureText = self.isSecureTextEntry
            setIconForSecureTextEntry()
        }
    }
    
    @IBInspectable
    var placeholderText: String = ""{
        didSet {
            placeholderLabel.text = "  " + placeholderText + "  "
            oldPlaceholder   = "  " + placeholderText + "  "
            placeholderLabel.layer.zPosition = 1
        }
    }
    
    @IBInspectable var leadingIcon: UIImage?{
        didSet{
            self.leadingButton.setImage(leadingIcon?.withRenderingMode(.alwaysTemplate), for: .normal)
            self.leftView      = leadingButton
            self.leftViewMode  = .always
            self.placeHolderLabelLeadingAnchor.constant = 45
        }
    }

    @IBInspectable var trailingIcon: UIImage?{
        didSet{
            trailingButton.setImage(trailingIcon?.withRenderingMode(.alwaysTemplate), for: .normal)
            self.rightView     = trailingButton
            self.rightViewMode = .always
        }
    }
    
    override var text: String?{
        didSet{
            self.placeholderStatus = self.text!.isEmpty ? .middle : .top
        }
    }
    
    //MARK: - UI Variable area
    private let placeholderLabel: UILabel = {
        let label = UILabel()
        label.font = Fonts.cairo.regular.font(size: 14)
        label.textColor = AppColor.gray.value
        label.backgroundColor = .clear
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let holderView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 8
        view.layer.masksToBounds = true
        view.layer.borderColor = AppColor.lightGray.value.cgColor
        view.layer.borderWidth = 1
        view.backgroundColor = AppColor.white.value
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let leadingButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setTitleColor(AppColor.gray.value, for: .normal)
        button.backgroundColor = AppColor.clear.value
        return button
    }()
    
    private let trailingButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setTitleColor(AppColor.gray.value, for: .normal)
        button.backgroundColor = AppColor.clear.value
        return button
    }()
    
    //MARK:  - LifeCycle
    override func awakeFromNib() {
        super.awakeFromNib()
        self.textColor = AppColor.black.value
        self.font = Fonts.cairo.regular.font(size: 16)
        delegate = self
        setupUI()
        turnOffAllUserInteractiveFor([holderView, placeholderLabel, leadingButton, trailingButton])
        feildStatus = .normal
    }
    
    //MARK: - TextField rect
    override open func textRect(forBounds bounds: CGRect) -> CGRect {
        setPadding()
        return bounds.inset(by: padding)
    }
    
    override open func placeholderRect(forBounds bounds: CGRect) -> CGRect {
        setPadding()
        return bounds.inset(by: padding)
    }
    
    override open func editingRect(forBounds bounds: CGRect) -> CGRect {
        setPadding()
        return bounds.inset(by: padding)
    }
    
    override func leftViewRect(forBounds bounds: CGRect) -> CGRect {
        return CGRect(x: bounds.origin.x, y: 20, width: 50, height: 60)
    }
    
    override func rightViewRect(forBounds bounds: CGRect) -> CGRect {
        return CGRect(x: bounds.maxX - 50, y: 20, width: 50, height: 60)
    }
    
    //MARK: - SetError
    func setError(text: String?){
        hasErrorValidation = text == nil ? false : true
        setPlaceholderForErrorValidation()
        self.placeholderLabel.text = text == nil ? oldPlaceholder : "  " + text! + "  "
        self.feildStatus       = .error
        self.placeholderStatus = .top
        guard text == nil else { return }
        self.feildStatus = placeholderStatus == .top ? .active : .normal
        guard makeTextFieldClcikable == true else{ return }
        self.feildStatus = .normal
    }
    
    private func setPlaceholderForErrorValidation(){
        let placeholder = hasErrorValidation ? oldPlaceholder : ""
        attributedPlaceholder = NSAttributedString(string: placeholder, attributes: [.foregroundColor: AppColor.red.value])
    }
    
}

//MARK: - Settings
private extension AppTextFeild {
    
    func setPadding(){
        if leadingIcon == nil && trailingIcon == nil {
            padding.left  = 20
            padding.right = 20
        }else if trailingIcon != nil && leadingIcon == nil {
            padding.right = UIApplication.shared.userInterfaceLayoutDirection == .rightToLeft ? 20 : 50
            if UIApplication.shared.userInterfaceLayoutDirection == .rightToLeft { padding.left = 50 }
        }else if leadingIcon != nil && trailingIcon == nil {
            padding.left = UIApplication.shared.userInterfaceLayoutDirection == .rightToLeft ? 20 : 50
            if UIApplication.shared.userInterfaceLayoutDirection == .rightToLeft { padding.right = 50 }
        }else if leadingIcon != nil && trailingIcon != nil  {
            padding.left  = 50
            padding.right = 50
        }
        
    }

    
    func turnOffAllUserInteractiveFor(_ views: [UIView]){
        views.forEach { $0.isUserInteractionEnabled = false }
    }
    
    func setIconForSecureTextEntry(){
        guard self.isSecureText == true else { return }
        trailingIcon = UIImage(systemName: "eye.slash")
        setPadding()
        trailingButton.isUserInteractionEnabled = true
        trailingButton.addTarget(self, action: #selector(self.showOrHidePasswordEvents), for: .touchUpInside)
    }
    
    func setupUI() {
        self.addSubview(placeholderLabel)
        self.addSubview(holderView)
        holderView.translatesAutoresizingMaskIntoConstraints = false
        placeholderLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            //PlaceholderLabel
            placeholderLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: 35),
            //HolderView
            holderView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            holderView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            holderView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            holderView.heightAnchor.constraint(equalToConstant: 60)
        ])
        
        self.placeHolderLabelLeadingAnchor = placeholderLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 16)
        self.placeHolderLabelLeadingAnchor.isActive = true
        
    }
    
    @objc func showOrHidePasswordEvents(){
        self.isSecureTextEntry.toggle()
        trailingIcon = UIImage(systemName: self.isSecureTextEntry ? "eye.slash" : "eye")
        setPadding()
    }
    
}

//MARK: - TextFeildDelegate
extension AppTextFeild: UITextFieldDelegate {
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        placeholderStatus = .top
        textFieldDelegate?.textFieldDidBeginEditing?(textField)
        guard hasErrorValidation == false else { return }
        self.feildStatus = .active
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        switch feildStatus == .error {
        case true:
            placeholderStatus = .top
        case false:
            placeholderStatus = textField.text!.isEmpty ? .middle : .top
        }
        textFieldDelegate?.textFieldDidEndEditing?(textField)
        guard hasErrorValidation == false else { return }
        self.feildStatus = .normal
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if makeTextFieldClcikable == true {
            endEditing(true)
            self.textFieldDelegate?.didTextFieldClicked?(textField)
        }
        
        return !makeTextFieldClcikable
    }
    
}

//MARK: - Animation
private extension AppTextFeild {
    
    func changePlaceholderPosition(){
        let topStatusPlaceHolderValue: CGFloat = UIApplication.shared.userInterfaceLayoutDirection == .rightToLeft ? 28 : -28
        let rightInset: CGFloat = self.leadingIcon == nil ? 0 : topStatusPlaceHolderValue
        UIViewPropertyAnimator(duration: 0.4, dampingRatio: 0.7) { [weak self] in
            guard let self = self else { return }
            self.placeholderLabel.transform = self.placeholderStatus == .middle ? .identity : CGAffineTransform(translationX: rightInset, y: -30)
            self.placeholderLabel.backgroundColor = self.placeholderStatus == .middle ? AppColor.clear.value : self.placeholderBackgroundColor
        }.startAnimation()
    }
}

//MARK: - FeildStats
private extension AppTextFeild {
    
    func changeFeildStatus(){
        switch self.feildStatus {
        case .normal:
            styleForTextField(color: .gray)
        case .active:
            styleForTextField(color: .blue)
        case .error:
            styleForTextField(color: .red)
        }
    }

    
    func styleForTextField(color: AppColor){
        placeholderLabel.textColor = color.value
        holderView.layer.borderColor = color.value.cgColor
        holderView.layer.borderWidth = 1
        leadingButton.tintColor = color.value
        trailingButton.tintColor = color.value
        self.tintColor = color.value
    }
    
}



