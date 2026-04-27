#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Markov Chain Forecasting for 6/45 Lottery
Using transition probabilities to predict next draw
"""

import pandas as pd
import numpy as np
from collections import defaultdict
import json
from datetime import datetime

class MarkovLotteryPredictor:
    def __init__(self, data_path):
        """Initialize with lottery data"""
        self.df = pd.read_csv(data_path)
        self.columns = ['s1', 's2', 's3', 's4', 's5', 's6']
        self.constraints = {
            's1': (1, 31),
            's2': (2, 39),
            's3': (3, 40),
            's4': (4, 43),
            's5': (5, 44),
            's6': (6, 45)
        }
        self.transition_matrices = {}
        self.state_counts = {}
        
    def build_transition_matrix(self):
        """Build transition probability matrices for each position"""
        for col in self.columns:
            # Initialize transition matrix
            min_val, max_val = self.constraints[col]
            range_size = max_val - min_val + 1
            
            trans_matrix = defaultdict(lambda: defaultdict(int))
            state_freq = defaultdict(int)
            
            # Count transitions
            values = self.df[col].values
            for i in range(len(values) - 1):
                current_state = values[i]
                next_state = values[i + 1]
                trans_matrix[current_state][next_state] += 1
                state_freq[current_state] += 1
            
            # Convert to probabilities
            prob_matrix = {}
            for current, next_states in trans_matrix.items():
                total = sum(next_states.values())
                prob_matrix[current] = {}
                for next_state, count in next_states.items():
                    prob_matrix[current][next_state] = count / total
            
            self.transition_matrices[col] = prob_matrix
            self.state_counts[col] = dict(state_freq)
    
    def predict_next_value(self, current_value, col_name):
        """Predict next value using Markov chain"""
        if col_name not in self.transition_matrices:
            return None
        
        prob_matrix = self.transition_matrices[col_name]
        
        if current_value not in prob_matrix:
            # Fallback: return most likely state overall
            min_val, max_val = self.constraints[col_name]
            all_states = dict(self.state_counts[col_name])
            if all_states:
                return max(all_states, key=all_states.get)
            return (min_val + max_val) // 2
        
        # Get probabilities for next state
        next_probs = prob_matrix[current_value]
        
        # Return state with highest probability
        if next_probs:
            return max(next_probs, key=next_probs.get)
        return current_value
    
    def predict_draw(self, idx):
        """Predict complete draw at index idx"""
        if idx < 1 or idx >= len(self.df):
            return None
        
        current_draw = self.df.iloc[idx - 1][self.columns].values
        predicted_draw = []
        
        for i, col in enumerate(self.columns):
            next_val = self.predict_next_value(current_draw[i], col)
            predicted_draw.append(next_val)
        
        return predicted_draw
    
    def backtest(self, start_idx=1, end_idx=None):
        """Backtest predictions vs actual results"""
        if end_idx is None:
            end_idx = len(self.df)
        
        results = {
            'exact_matches': 0,
            'partial_matches': {i: 0 for i in range(1, 7)},  # at least i numbers match
            'predictions': [],
            'actuals': [],
            'accuracy_by_position': {col: {'correct': 0, 'total': 0} for col in self.columns},
            'total_tests': 0
        }
        
        for idx in range(start_idx, min(end_idx, len(self.df))):
            predicted = self.predict_draw(idx)
            actual = self.df.iloc[idx][self.columns].values.tolist()
            
            if predicted is None:
                continue
            
            results['total_tests'] += 1
            results['predictions'].append(predicted)
            results['actuals'].append(actual)
            
            # Count matches
            matches = sum(1 for p, a in zip(predicted, actual) if p == a)
            
            if matches == 6:
                results['exact_matches'] += 1
            
            for threshold in range(1, 7):
                if matches >= threshold:
                    results['partial_matches'][threshold] += 1
            
            # Per-position accuracy
            for i, col in enumerate(self.columns):
                results['accuracy_by_position'][col]['total'] += 1
                if predicted[i] == actual[i]:
                    results['accuracy_by_position'][col]['correct'] += 1
        
        return results
    
    def get_statistics(self):
        """Get detailed statistics"""
        stats = {}
        for col in self.columns:
            min_val, max_val = self.constraints[col]
            values = self.df[col].values
            
            stats[col] = {
                'mean': float(np.mean(values)),
                'std': float(np.std(values)),
                'min': float(np.min(values)),
                'max': float(np.max(values)),
                'unique_values': len(np.unique(values)),
                'most_common': int(max(self.state_counts[col], key=self.state_counts[col].get))
                if self.state_counts[col] else None
            }
        return stats
    
    def get_next_prediction(self):
        """Get prediction for next draw after last record"""
        last_idx = len(self.df) - 1
        predicted = self.predict_draw(last_idx)
        
        if predicted:
            # Sort the values for proper 6/45 format
            return sorted(predicted)
        return None


def main():
    print("=" * 70)
    print("MARKOV CHAIN LOTTERY PREDICTION SYSTEM")
    print("=" * 70)
    
    # Initialize predictor
    predictor = MarkovLotteryPredictor('aipl/mega6b45.csv')
    
    print("\n1. Building Markov transition matrices...")
    predictor.build_transition_matrix()
    print("   ✓ Transition matrices built for all 6 positions")
    
    print("\n2. Generating statistics...")
    stats = predictor.get_statistics()
    for col, stat in stats.items():
        print(f"\n   {col}:")
        print(f"      Mean: {stat['mean']:.2f}, Std: {stat['std']:.2f}")
        print(f"      Range: [{stat['min']:.0f}, {stat['max']:.0f}]")
        print(f"      Unique values: {stat['unique_values']}")
        print(f"      Most common: {stat['most_common']}")
    
    print("\n3. Running backtesting (this may take a moment)...")
    results = predictor.backtest(start_idx=1)
    
    print(f"\n   Total tests: {results['total_tests']}")
    print(f"   Exact matches (6/6): {results['exact_matches']}")
    print(f"   Match rate by threshold:")
    for threshold in range(1, 7):
        count = results['partial_matches'][threshold]
        pct = (count / results['total_tests'] * 100) if results['total_tests'] > 0 else 0
        print(f"      At least {threshold} numbers: {count} ({pct:.2f}%)")
    
    print(f"\n   Per-position accuracy:")
    for col in predictor.columns:
        acc = results['accuracy_by_position'][col]
        pct = (acc['correct'] / acc['total'] * 100) if acc['total'] > 0 else 0
        print(f"      {col}: {acc['correct']}/{acc['total']} ({pct:.2f}%)")
    
    print("\n4. Predicting next draw...")
    next_pred = predictor.get_next_prediction()
    if next_pred:
        print(f"\n   PREDICTED NEXT DRAW: {next_pred}")
    
    print("\n5. Sample predictions (last 10 draws):")
    start = max(1, len(predictor.df) - 10)
    for idx in range(start, len(predictor.df)):
        pred = predictor.predict_draw(idx)
        actual = predictor.df.iloc[idx][predictor.columns].values.tolist()
        matches = sum(1 for p, a in zip(pred, actual) if p == a)
        print(f"   Period {predictor.df.iloc[idx]['Kỳ']}: "
              f"Predicted {pred}, Actual {actual}, Matches: {matches}")
    
    print("\n" + "=" * 70)
    print("Analysis complete!")
    print("=" * 70)
    
    # Save results to JSON
    output_data = {
        'timestamp': datetime.now().isoformat(),
        'total_records': len(predictor.df),
        'next_prediction': next_pred,
        'backtest_results': {
            'total_tests': results['total_tests'],
            'exact_matches': results['exact_matches'],
            'partial_matches': {str(k): v for k, v in results['partial_matches'].items()},
            'position_accuracy': {
                col: {
                    'correct': results['accuracy_by_position'][col]['correct'],
                    'total': results['accuracy_by_position'][col]['total'],
                    'percentage': (results['accuracy_by_position'][col]['correct'] / 
                                 results['accuracy_by_position'][col]['total'] * 100)
                    if results['accuracy_by_position'][col]['total'] > 0 else 0
                }
                for col in predictor.columns
            }
        },
        'statistics': stats
    }
    
    with open('aipl/markov_prediction_results.json', 'w', encoding='utf-8') as f:
        json.dump(output_data, f, ensure_ascii=False, indent=2)
    
    print("\n✓ Results saved to: markov_prediction_results.json")


if __name__ == '__main__':
    main()
