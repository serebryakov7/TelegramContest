//
//  ChartsTableView.swift
//  TelegramChart
//
//  Created by Ivan Serebryakov on 21/03/2019.
//  Copyright © 2019 Ivan Serebryakov. All rights reserved.
//

import Foundation
import UIKit

fileprivate struct ChartTableViewCellIdentifier {
    static let cellButtonIdentifier = "button_cell_reuse"
    static let cellLineIdentifier = "line_cell_reuse"
    static let cellChartIdentifier = "chart_cell_reuse"
}

fileprivate struct ChartsTableViewConstants {
    static let label = "FOLLOWERS"
}

final class ChartsTableView : UITableView {
    
    var charts: Array<Chart> = []

    override init(frame: CGRect, style: UITableView.Style) {
        super.init(frame: frame, style: style)
        
        register(ThemeSwitchTableViewCell.self, forCellReuseIdentifier: ChartTableViewCellIdentifier.cellButtonIdentifier)
        register(GraphPickerTableViewCell.self, forCellReuseIdentifier: ChartTableViewCellIdentifier.cellLineIdentifier)
        register(ChartTableViewCell.self, forCellReuseIdentifier: ChartTableViewCellIdentifier.cellChartIdentifier)
        
        allowsMultipleSelection = true
        separatorStyle = .none
        delegate = self
        dataSource = self
        tableFooterView = UIView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}

extension ChartsTableView: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return charts.count + 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section != charts.count ? charts[section].graphs.count + 1 : 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == charts.count {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: ChartTableViewCellIdentifier.cellButtonIdentifier, for: indexPath) as? ThemeSwitchTableViewCell else { fatalError() }
            
            cell.selectionStyle = .none
            cell.button.setTitle(Theme.shared.switchButtonText, for: .normal)
            cell.button.setTitleColor(Theme.shared.buttonTextColor, for: .normal)
            cell.button.backgroundColor = Theme.shared.mainColor
            
            return cell
        } else {
            if indexPath.row == 0 {
                guard let cell = tableView.dequeueReusableCell(withIdentifier: ChartTableViewCellIdentifier.cellChartIdentifier, for: indexPath) as? ChartTableViewCell else {
                    fatalError()
                }
                
                cell.selectionStyle = .none
                cell.backgroundColor = Theme.shared.mainColor
                
                cell.contentView.backgroundColor = Theme.shared.mainColor
                
                cell.setChart(charts[indexPath.section])
                
                cell.onSelectorChartUpdateCallback = { [weak self] chart in
                    self?.charts[indexPath.section] = chart
                }
                return cell
                
            } else {
                guard let cell = tableView.dequeueReusableCell(withIdentifier: ChartTableViewCellIdentifier.cellLineIdentifier, for: indexPath) as? GraphPickerTableViewCell else { fatalError() }
                
                let item = charts[indexPath.section].graphs[indexPath.row - 1]
                
                if !item.isHidden {
                    tableView.selectRow(at: indexPath, animated: false, scrollPosition: .none)
                }
                
                cell.isSelected = !item.isHidden
                
                cell.selectionStyle = .none
                cell.titleLabel.textColor = Theme.shared.mainTextColor
                cell.backgroundColor = Theme.shared.mainColor
                cell.titleLabel.text = item.name
                cell.rectView.backgroundColor = item.color
                
                if indexPath.row != charts[indexPath.section].graphs.count {
                    cell.bottomView.isHidden = false
                    cell.bottomView.backgroundColor = Theme.shared.additionalColor
                    return cell
                }
                
                cell.bottomView.isHidden = true
                
                return cell
            }
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return section == charts.count ? setupView() : setupHeaderView()
    }
}

func setupView() -> UIView {
    let view = UIView()
    view.backgroundColor = Theme.shared.additionalColor
    return view
}

func setupHeaderView() -> HeaderView {
    let view = HeaderView()
    view.titleLabel.text = ChartsTableViewConstants.label
    view.backgroundColor = Theme.shared.additionalColor
    view.titleLabel.textColor = Theme.shared.additionalTextColor
    return view
}

extension ChartsTableView : UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section != charts.count, indexPath.row != 0 {
            charts[indexPath.section].graphs[indexPath.row - 1].isHidden = false
            if let cell = tableView.cellForRow(at: indexPath) {
                cell.isSelected = true
                if let graphCell = tableView.cellForRow(at: IndexPath(row: 0, section: indexPath.section)) as? ChartTableViewCell {
                    graphCell.setChart(charts[indexPath.section])
                }
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        if indexPath.section != charts.count, indexPath.row != 0 {
            charts[indexPath.section].graphs[indexPath.row - 1].isHidden = true
            if let cell = tableView.cellForRow(at: indexPath) {
                cell.isSelected = false
                if let graphCell = tableView.cellForRow(at: IndexPath(row: 0, section: indexPath.section)) as? ChartTableViewCell {
                    graphCell.setChart(charts[indexPath.section])
                }
            }
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return
            (indexPath.section != charts.count && indexPath.row == 0)
                ? tableView.bounds.width
                : 50
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return
            section == charts.count
                ? 40
                : 60
    }
}
