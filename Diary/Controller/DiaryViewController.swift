//
//  DiaryViewController.swift
//  Diary
//
//  Created by Dasan, kyungmin on 2023/08/28.
//

import UIKit

final class DiaryViewController: UIViewController {
    private lazy var collectionView: UICollectionView = {
        let configuration = UICollectionLayoutListConfiguration(appearance: .plain)
        let listLayout = UICollectionViewCompositionalLayout.list(using: configuration)
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: listLayout)
        
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.delegate = self
        
        return collectionView
    }()
    private var diaryDataSource: UICollectionViewDiffableDataSource<Section, Diary>?
    private var useCase: DiaryViewControllerUseCase?
    
    init(useCase: DiaryViewControllerUseCase) {
        self.useCase = useCase
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupObject()
        configureUI()
        setupConstraint()
        configureDataSource()
        loadData()
        applySnapshot()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        applySnapshot()
    }
}

// MARK: Setup Object
extension DiaryViewController {
    private func setupObject() {
        setupView()
        setupNavigationBar()
        setupUseCase()
    }
    
    private func setupView() {
        view.backgroundColor = .white
    }
    
    private func setupNavigationBar() {
        let selectDateButton = UIBarButtonItem(
            image: UIImage(systemName: NameSpace.plusButtonImage),
            style: .plain,
            target: self,
            action: #selector(didTapSelectPlusButton)
        )
        navigationItem.title = NameSpace.diaryTitle
        navigationItem.rightBarButtonItem = selectDateButton
    }
    
    private func setupUseCase() {
        useCase?.delegate = self
    }
}

// MARK: Configure UI
extension DiaryViewController {
    private func configureUI() {
        configureView()
    }
    
    private func configureView() {
        view.addSubview(collectionView)
    }
}

// MARK: Setup Constraints
extension DiaryViewController {
    private func setupConstraint() {
        setupCollectionViewConstraint()
    }
    
    private func setupCollectionViewConstraint() {
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            collectionView.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor),
            collectionView.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor)
        ])
    }
}

// MARK: Load Data
extension DiaryViewController {
    private func loadData() {
        useCase?.fetchDiaryList()
    }
}

// MARK: DiaryDetailViewController Delegate
extension DiaryViewController: DiaryDetailViewControllerDelegate {
    func diaryDetailViewController(_ diaryDetailViewController: DiaryDetailViewController, upsert diary: Diary) {
        useCase?.upsert(diary)
        loadData()
    }
    
    func diaryDetailViewController(_ diaryDetailViewController: DiaryDetailViewController, delete diary: Diary) {
        useCase?.delete(diary)
        loadData()
    }
    
    func diaryDetailViewController(dismiss diaryDetailViewController: DiaryDetailViewController) {
        diaryDetailViewController.dismiss(animated: true)
    }
}

// MARK: CollectionView Delegate
extension DiaryViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let diary = useCase?.diaryList[indexPath.item] else {
            return
        }
        
        let diaryDetailViewControllerUseCase = DiaryDetailViewControllerUseCase(diary: diary)
        let diaryDetailViewController = DiaryDetailViewController(useCase: diaryDetailViewControllerUseCase, delegate: self)
        
        show(diaryDetailViewController, sender: self)
        collectionView.deselectItem(at: indexPath, animated: true)
    }
}

// MARK: CollectionView DataSource
extension DiaryViewController {
    private func configureDataSource() {
        let registration = UICollectionView.CellRegistration<DiaryCollectionViewListCell, Diary> { cell, _, diary in
            cell.setupLabels(diary)
        }

        diaryDataSource = UICollectionViewDiffableDataSource<Section, Diary>(collectionView: collectionView) { collectionView, indexPath, diary in
            return collectionView.dequeueConfiguredReusableCell(using: registration, for: indexPath, item: diary)
        }
    }
    
    private func applySnapshot() {
        guard let diaryList = useCase?.diaryList, let diaryDataSource else {
            return
        }
        
        var snapshot = NSDiffableDataSourceSnapshot<Section, Diary>()
        
        snapshot.appendSections([.main])
        snapshot.appendItems(diaryList)
        diaryDataSource.apply(snapshot, animatingDifferences: true)
    }
}

// MARK: CollectionView Layout
extension DiaryViewController {
    private func listLayout() -> UICollectionViewLayout {
        let configuration = UICollectionLayoutListConfiguration(appearance: .plain)
        
        return UICollectionViewCompositionalLayout.list(using: configuration)
    }
}

// MARK: CollectionView Section
extension DiaryViewController {
    private enum Section {
        case main
    }
}

// MARK: Alert Action
extension DiaryViewController: DiaryViewControllerUseCaseDelegate {
    func showErrorAlert(error: Error) {
        let alertAction = UIAlertAction(title: NameSpace.check, style: .default)
        let alert = UIAlertController.customAlert(
            alertTile: NameSpace.error,
            alertMessage: error.localizedDescription,
            preferredStyle: .alert,
            alertActions: [alertAction]
        )
        
        navigationController?.present(alert, animated: true)
    }
}

// MARK: Button Action
extension DiaryViewController {
    @objc private func didTapSelectPlusButton() {
        guard let diary = useCase?.newDiary() else {
            return
        }
        
        let diaryDetailViewControllerUseCase = DiaryDetailViewControllerUseCase(diary: diary)
        let diaryDetailViewController = DiaryDetailViewController(useCase: diaryDetailViewControllerUseCase, delegate: self)
        
        show(diaryDetailViewController, sender: self)
    }
}

// MARK: Name Space
extension DiaryViewController {
    private enum NameSpace {
        static let diaryTitle = "일기장"
        static let plusButtonImage = "plus"
        static let check = "확인"
        static let error = "Error"
        static let deleteTitle = "진짜요?"
        static let deleteSubtitle = "정말로 삭제하시겠습니까?"
        static let cancel = "취소"
        static let delete = "삭제"
    }
}
