import XCTest
import RxSwift
import RxTest
import RxBlocking


@testable import rx_blocking_test_ios

class RxCollectorTests: XCTestCase {

    var isVisible: Variable<Bool> = Variable<Bool>(false)
    var isHidden: Observable<Bool> = Observable<Bool>.create { observer in
        observer.onNext(false)
        observer.onNext(true)
        observer.onCompleted()
        return Disposables.create()
    }
    var onTapped: PublishSubject<Void> = PublishSubject<Void>()
    var disposeBag: DisposeBag = DisposeBag()

    func testVariableBoolCollector() {
        let collector = RxCollector<Bool>().collect(from: isVisible.asObservable())
        isVisible.value = false
        isVisible.value = false
        isVisible.value = true

        XCTAssertEqual(collector.toArray, [false, false, false, true])
    }

    func testObservableBoolCollector() {
        let collector = RxCollector<Bool>().collect(from: isHidden)
        XCTAssertEqual(collector.toArray, [false, true])
    }

    func testVoidCollector() {
        let collector = RxCollector<Void>().collect(from: onTapped.asObservable())
        onTapped.onNext(())
        onTapped.onNext(())
        onTapped.onNext(())
        XCTAssertEqual(collector.toArray.count, 3)
    }

    func test_WhenLoginIsSuccesfulProgressIsDisplayedCorrect() {
        let userViewModel: UserViewModel = UserViewModel()

        let loginProgresCollector = RxCollector<Bool>()
            .collect(from: userViewModel.loginProgres.asObservable())
        let displayAlertDialogCollector = RxCollector<Void>()
            .collect(from: userViewModel.displayAlertDialog)
        let reloadTableViewCollector = RxCollector<Void>()
            .collect(from: userViewModel.reloadTableView)

        let expection = self.expectation(description: "")
        userViewModel.login(makeFail: false)
            .subscribe(onNext: { _ in
        }, onCompleted: {
            expection.fulfill()
        }).addDisposableTo(disposeBag)
        wait(for: [expection], timeout: 10)

        XCTAssertEqual(loginProgresCollector.toArray, [false, true, false])
        XCTAssertEqual(displayAlertDialogCollector.toArray.count, 0)
        XCTAssertEqual(reloadTableViewCollector.toArray.count, 1)
    }

}

class UserViewModel {

    private(set) var loginProgres: Variable<Bool> = Variable<Bool>(false)
    private(set) var reloadTableView: PublishSubject<Void> = PublishSubject<Void>()
    private(set) var displayAlertDialog: PublishSubject<Void> = PublishSubject<Void>()
    var disposeBag: DisposeBag = DisposeBag()
    private let apiClient: ApiClient = ApiClient()

    func login(makeFail: Bool) -> Observable<Void> {
        loginProgres.value = true
        return apiClient.login(makeFail: makeFail)
            .observeOn(MainScheduler.instance)
            .do(onError: { [weak self] (_) in
            self?.loginProgres.value = false
            self?.displayAlertDialog.onNext(())
        }, onCompleted: { [weak self] in
            self?.loginProgres.value = false
            self?.reloadTableView.onNext(())
        })
    }
}

class ApiClient {

    func login(makeFail: Bool) -> Observable<Void> {
        return Observable<Void>.create { observer in
            DispatchQueue.global(qos: .background).async {
                if makeFail {
                    observer.onError(NSError(domain: "", code: 0, userInfo: nil))
                } else {
                    observer.onNext(())
                    observer.onCompleted()
                }
            }
            return Disposables.create()
        }
    }

}

class RxCollector<T> {

    var deadBodies: DisposeBag = DisposeBag()
    var toArray: [T] = [T]()

    func collect(from observable: Observable<T>) -> RxCollector {
        observable.asObservable()
            .subscribe(onNext: { (newZombie) in
                self.toArray.append(newZombie)
            }).addDisposableTo(deadBodies)
        return self
    }

}



