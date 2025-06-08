#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Script de création de base de données pour l'application Child Security
"""

import sqlite3
import os
from datetime import datetime
from typing import Optional, List, Dict, Any

class DatabaseHelper:
    """Helper class pour la gestion de la base de données SQLite"""
    
    def __init__(self, db_path: str = "base_donnée.db"):
        """
        Initialise la connexion à la base de données
        
        Args:
            db_path: Chemin vers le fichier de base de données
        """
        self.db_path = db_path
        self.connection: Optional[sqlite3.Connection] = None
        
    def connect(self) -> sqlite3.Connection:
        """Établit la connexion à la base de données"""
        if not self.connection:
            self.connection = sqlite3.connect(self.db_path)
            self.connection.row_factory = sqlite3.Row  # Pour accéder aux colonnes par nom
        return self.connection
    
    def close(self):
        """Ferme la connexion à la base de données"""
        if self.connection:
            self.connection.close()
            self.connection = None
    
    def create_tables(self):
        """Crée toutes les tables nécessaires"""
        cursor = self.connect().cursor()
        
        # =============================================
        # TABLES POUR LA COMMUNAUTÉ ET LE CHAT
        # =============================================
        
        # Table des utilisateurs/parents
        cursor.execute('''
            CREATE TABLE IF NOT EXISTS users (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                name TEXT NOT NULL,
                email TEXT UNIQUE NOT NULL,
                phone TEXT,
                avatar_url TEXT,
                address TEXT,
                latitude REAL,
                longitude REAL,
                rating REAL DEFAULT 4.0,
                is_verified BOOLEAN DEFAULT 0,
                is_active BOOLEAN DEFAULT 1,
                join_date TEXT NOT NULL,
                last_seen TEXT,
                children_count INTEGER DEFAULT 1,
                bio TEXT,
                preferred_language TEXT DEFAULT 'fr',
                notification_token TEXT,
                privacy_settings TEXT DEFAULT '{"profile_visible": true, "location_sharing": false}',
                created_at TEXT DEFAULT CURRENT_TIMESTAMP,
                updated_at TEXT DEFAULT CURRENT_TIMESTAMP
            )
        ''')
        
        # Table des connexions entre parents
        cursor.execute('''
            CREATE TABLE IF NOT EXISTS parent_connections (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                user1_id INTEGER NOT NULL,
                user2_id INTEGER NOT NULL,
                status TEXT DEFAULT 'pending',
                connection_date TEXT NOT NULL,
                last_interaction TEXT,
                trust_score REAL DEFAULT 3.0,
                created_at TEXT DEFAULT CURRENT_TIMESTAMP,
                FOREIGN KEY (user1_id) REFERENCES users (id) ON DELETE CASCADE,
                FOREIGN KEY (user2_id) REFERENCES users (id) ON DELETE CASCADE,
                UNIQUE(user1_id, user2_id)
            )
        ''')
        
        # Table des conversations
        cursor.execute('''
            CREATE TABLE IF NOT EXISTS conversations (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                title TEXT,
                type TEXT DEFAULT 'private',
                created_by INTEGER NOT NULL,
                created_at TEXT DEFAULT CURRENT_TIMESTAMP,
                updated_at TEXT DEFAULT CURRENT_TIMESTAMP,
                is_active BOOLEAN DEFAULT 1,
                last_message_at TEXT,
                participants_count INTEGER DEFAULT 2,
                conversation_settings TEXT DEFAULT '{}',
                FOREIGN KEY (created_by) REFERENCES users (id) ON DELETE CASCADE
            )
        ''')
        
        # Table des participants aux conversations
        cursor.execute('''
            CREATE TABLE IF NOT EXISTS conversation_participants (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                conversation_id INTEGER NOT NULL,
                user_id INTEGER NOT NULL,
                role TEXT DEFAULT 'member',
                joined_at TEXT DEFAULT CURRENT_TIMESTAMP,
                last_read_at TEXT,
                is_muted BOOLEAN DEFAULT 0,
                is_active BOOLEAN DEFAULT 1,
                FOREIGN KEY (conversation_id) REFERENCES conversations (id) ON DELETE CASCADE,
                FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE,
                UNIQUE(conversation_id, user_id)
            )
        ''')
        
        # Table des messages
        cursor.execute('''
            CREATE TABLE IF NOT EXISTS messages (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                conversation_id INTEGER NOT NULL,
                sender_id INTEGER NOT NULL,
                content TEXT NOT NULL,
                message_type TEXT DEFAULT 'text',
                media_url TEXT,
                sent_at TEXT DEFAULT CURRENT_TIMESTAMP,
                is_edited BOOLEAN DEFAULT 0,
                edited_at TEXT,
                reply_to_message_id INTEGER,
                status TEXT DEFAULT 'sent',
                location_data TEXT,
                FOREIGN KEY (conversation_id) REFERENCES conversations (id) ON DELETE CASCADE,
                FOREIGN KEY (sender_id) REFERENCES users (id) ON DELETE CASCADE,
                FOREIGN KEY (reply_to_message_id) REFERENCES messages (id)
            )
        ''')
        
        # Table des réactions aux messages
        cursor.execute('''
            CREATE TABLE IF NOT EXISTS message_reactions (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                message_id INTEGER NOT NULL,
                user_id INTEGER NOT NULL,
                reaction_type TEXT NOT NULL,
                created_at TEXT DEFAULT CURRENT_TIMESTAMP,
                FOREIGN KEY (message_id) REFERENCES messages (id) ON DELETE CASCADE,
                FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE,
                UNIQUE(message_id, user_id, reaction_type)
            )
        ''')
        
        # =============================================
        # TABLES POUR LES ALERTES COMMUNAUTAIRES
        # =============================================
        
        # Table des alertes communautaires
        cursor.execute('''
            CREATE TABLE IF NOT EXISTS community_alerts (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                user_id INTEGER NOT NULL,
                title TEXT NOT NULL,
                description TEXT NOT NULL,
                alert_type TEXT NOT NULL,
                severity TEXT DEFAULT 'medium',
                latitude REAL NOT NULL,
                longitude REAL NOT NULL,
                address TEXT,
                created_at TEXT DEFAULT CURRENT_TIMESTAMP,
                updated_at TEXT DEFAULT CURRENT_TIMESTAMP,
                is_resolved BOOLEAN DEFAULT 0,
                resolved_by INTEGER,
                resolved_at TEXT,
                views_count INTEGER DEFAULT 0,
                media_urls TEXT,
                contact_info TEXT,
                FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE,
                FOREIGN KEY (resolved_by) REFERENCES users (id)
            )
        ''')
        
        # Table des commentaires sur les alertes
        cursor.execute('''
            CREATE TABLE IF NOT EXISTS alert_comments (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                alert_id INTEGER NOT NULL,
                user_id INTEGER NOT NULL,
                comment TEXT NOT NULL,
                created_at TEXT DEFAULT CURRENT_TIMESTAMP,
                is_helpful BOOLEAN DEFAULT 0,
                helpful_count INTEGER DEFAULT 0,
                FOREIGN KEY (alert_id) REFERENCES community_alerts (id) ON DELETE CASCADE,
                FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE
            )
        ''')
        
        # =============================================
        # TABLES POUR L'ENTRAIDE
        # =============================================
        
        # Table des demandes d'aide
        cursor.execute('''
            CREATE TABLE IF NOT EXISTS help_requests (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                requester_id INTEGER NOT NULL,
                title TEXT NOT NULL,
                description TEXT NOT NULL,
                category TEXT NOT NULL,
                urgency TEXT DEFAULT 'normal',
                latitude REAL,
                longitude REAL,
                created_at TEXT DEFAULT CURRENT_TIMESTAMP,
                updated_at TEXT DEFAULT CURRENT_TIMESTAMP,
                is_resolved BOOLEAN DEFAULT 0,
                responses_count INTEGER DEFAULT 0,
                FOREIGN KEY (requester_id) REFERENCES users (id) ON DELETE CASCADE
            )
        ''')
        
        # Table des réponses aux demandes d'aide
        cursor.execute('''
            CREATE TABLE IF NOT EXISTS help_responses (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                request_id INTEGER NOT NULL,
                responder_id INTEGER NOT NULL,
                response TEXT NOT NULL,
                contact_method TEXT,
                created_at TEXT DEFAULT CURRENT_TIMESTAMP,
                is_accepted BOOLEAN DEFAULT 0,
                rating REAL,
                feedback TEXT,
                FOREIGN KEY (request_id) REFERENCES help_requests (id) ON DELETE CASCADE,
                FOREIGN KEY (responder_id) REFERENCES users (id) ON DELETE CASCADE
            )
        ''')
        
        # =============================================
        # TABLES POUR L'ÉDUCATION
        # =============================================
        
        # Table des catégories éducatives
        cursor.execute('''
            CREATE TABLE IF NOT EXISTS education_categories (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                name TEXT NOT NULL UNIQUE,
                description TEXT,
                icon TEXT,
                sort_order INTEGER DEFAULT 0,
                is_active BOOLEAN DEFAULT 1,
                created_at TEXT DEFAULT CURRENT_TIMESTAMP
            )
        ''')
        
        # Table du contenu éducatif
        cursor.execute('''
            CREATE TABLE IF NOT EXISTS educational_content (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                category_id INTEGER NOT NULL,
                title TEXT NOT NULL,
                content TEXT NOT NULL,
                content_type TEXT DEFAULT 'article',
                difficulty_level TEXT DEFAULT 'beginner',
                estimated_duration INTEGER DEFAULT 5,
                media_url TEXT,
                thumbnail_url TEXT,
                views_count INTEGER DEFAULT 0,
                average_rating REAL DEFAULT 0.0,
                created_at TEXT DEFAULT CURRENT_TIMESTAMP,
                updated_at TEXT DEFAULT CURRENT_TIMESTAMP,
                is_published BOOLEAN DEFAULT 1,
                tags TEXT,
                author TEXT,
                likes_count INTEGER DEFAULT 0,
                FOREIGN KEY (category_id) REFERENCES education_categories (id) ON DELETE CASCADE
            )
        ''')
        
        # Table des questions de quiz
        cursor.execute('''
            CREATE TABLE IF NOT EXISTS quiz_questions (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                content_id INTEGER NOT NULL,
                question TEXT NOT NULL,
                options TEXT NOT NULL,
                correct_answer TEXT NOT NULL,
                explanation TEXT,
                points INTEGER DEFAULT 10,
                sort_order INTEGER DEFAULT 0,
                FOREIGN KEY (content_id) REFERENCES educational_content (id) ON DELETE CASCADE
            )
        ''')
        
        # Table du progrès utilisateur
        cursor.execute('''
            CREATE TABLE IF NOT EXISTS user_progress (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                user_id INTEGER NOT NULL,
                content_id INTEGER NOT NULL,
                progress_status TEXT DEFAULT 'not_started',
                score INTEGER DEFAULT 0,
                time_spent INTEGER DEFAULT 0,
                started_at TEXT,
                completed_at TEXT,
                last_accessed TEXT DEFAULT CURRENT_TIMESTAMP,
                notes TEXT,
                attempts_count INTEGER DEFAULT 0,
                FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE,
                FOREIGN KEY (content_id) REFERENCES educational_content (id) ON DELETE CASCADE,
                UNIQUE(user_id, content_id)
            )
        ''')
        
        # Table des conseils parentaux
        cursor.execute('''
            CREATE TABLE IF NOT EXISTS parenting_advice (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                author_id INTEGER NOT NULL,
                title TEXT NOT NULL,
                content TEXT NOT NULL,
                category TEXT NOT NULL,
                age_group TEXT,
                tags TEXT,
                views_count INTEGER DEFAULT 0,
                average_rating REAL DEFAULT 0.0,
                created_at TEXT DEFAULT CURRENT_TIMESTAMP,
                updated_at TEXT DEFAULT CURRENT_TIMESTAMP,
                is_featured BOOLEAN DEFAULT 0,
                source TEXT,
                likes_count INTEGER DEFAULT 0,
                shares_count INTEGER DEFAULT 0,
                FOREIGN KEY (author_id) REFERENCES users (id) ON DELETE CASCADE
            )
        ''')
        
        # Table des commentaires sur les conseils
        cursor.execute('''
            CREATE TABLE IF NOT EXISTS advice_comments (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                advice_id INTEGER NOT NULL,
                user_id INTEGER NOT NULL,
                comment TEXT NOT NULL,
                created_at TEXT DEFAULT CURRENT_TIMESTAMP,
                is_helpful BOOLEAN DEFAULT 0,
                helpful_count INTEGER DEFAULT 0,
                parent_comment_id INTEGER,
                FOREIGN KEY (advice_id) REFERENCES parenting_advice (id) ON DELETE CASCADE,
                FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE,
                FOREIGN KEY (parent_comment_id) REFERENCES advice_comments (id)
            )
        ''')
        
        # =============================================
        # TABLES SYSTÈME
        # =============================================
        
        # Table des interactions utilisateur
        cursor.execute('''
            CREATE TABLE IF NOT EXISTS user_interactions (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                user_id INTEGER NOT NULL,
                interaction_type TEXT NOT NULL,
                target_id INTEGER NOT NULL,
                target_type TEXT NOT NULL,
                interaction_data TEXT,
                created_at TEXT DEFAULT CURRENT_TIMESTAMP,
                FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE
            )
        ''')
        
        # Table des évaluations
        cursor.execute('''
            CREATE TABLE IF NOT EXISTS ratings (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                user_id INTEGER NOT NULL,
                target_id INTEGER NOT NULL,
                target_type TEXT NOT NULL,
                rating REAL NOT NULL CHECK(rating >= 1 AND rating <= 5),
                review TEXT,
                created_at TEXT DEFAULT CURRENT_TIMESTAMP,
                is_anonymous BOOLEAN DEFAULT 0,
                FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE,
                UNIQUE(user_id, target_id, target_type)
            )
        ''')
        
        # Table des notifications
        cursor.execute('''
            CREATE TABLE IF NOT EXISTS notifications (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                user_id INTEGER NOT NULL,
                title TEXT NOT NULL,
                message TEXT NOT NULL,
                type TEXT NOT NULL,
                data TEXT,
                is_read BOOLEAN DEFAULT 0,
                created_at TEXT DEFAULT CURRENT_TIMESTAMP,
                read_at TEXT,
                priority TEXT DEFAULT 'normal',
                FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE
            )
        ''')
        
        # Table des signalements
        cursor.execute('''
            CREATE TABLE IF NOT EXISTS reports (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                reporter_id INTEGER NOT NULL,
                target_id INTEGER NOT NULL,
                target_type TEXT NOT NULL,
                reason TEXT NOT NULL,
                description TEXT,
                status TEXT DEFAULT 'pending',
                created_at TEXT DEFAULT CURRENT_TIMESTAMP,
                reviewed_by INTEGER,
                reviewed_at TEXT,
                action_taken TEXT,
                FOREIGN KEY (reporter_id) REFERENCES users (id) ON DELETE CASCADE,
                FOREIGN KEY (reviewed_by) REFERENCES users (id)
            )
        ''')
        
        # Création des index pour optimiser les performances
        self._create_indexes(cursor)
        
        # Insertion des données initiales
        self._insert_initial_data(cursor)
        
        self.connection.commit()
        print("✅ Toutes les tables ont été créées avec succès!")
    
    def _create_indexes(self, cursor):
        """Crée les index pour optimiser les performances"""
        indexes = [
            "CREATE INDEX IF NOT EXISTS idx_users_email ON users(email)",
            "CREATE INDEX IF NOT EXISTS idx_users_location ON users(latitude, longitude)",
            "CREATE INDEX IF NOT EXISTS idx_messages_conversation ON messages(conversation_id, sent_at)",
            "CREATE INDEX IF NOT EXISTS idx_alerts_location ON community_alerts(latitude, longitude)",
            "CREATE INDEX IF NOT EXISTS idx_alerts_type ON community_alerts(alert_type, created_at)",
            "CREATE INDEX IF NOT EXISTS idx_notifications_user ON notifications(user_id, is_read)",
            "CREATE INDEX IF NOT EXISTS idx_user_progress_user ON user_progress(user_id, progress_status)",
            "CREATE INDEX IF NOT EXISTS idx_connections_users ON parent_connections(user1_id, user2_id)",
        ]
        
        for index_sql in indexes:
            cursor.execute(index_sql)
    
    def _insert_initial_data(self, cursor):
        """Insère les données initiales nécessaires"""
        # Catégories éducatives par défaut
        categories = [
            ("Sécurité Internet", "Apprendre à naviguer en sécurité sur internet", "🌐", 1),
            ("Prévention des Dangers", "Identifier et éviter les situations dangereuses", "⚠️", 2),
            ("Communication", "Développer une communication ouverte avec votre enfant", "💬", 3),
            ("Premiers Secours", "Gestes de premiers secours pour enfants", "🚑", 4),
            ("Éducation Émotionnelle", "Aider votre enfant à gérer ses émotions", "❤️", 5),
        ]
        
        cursor.executemany('''
            INSERT OR IGNORE INTO education_categories (name, description, icon, sort_order)
            VALUES (?, ?, ?, ?)
        ''', categories)
        
        print("✅ Données initiales insérées!")

def main():
    """Fonction principale pour créer la base de données"""
    print("🚀 Création de la base de données Child Security...")
    
    # Création du dossier de données s'il n'existe pas
    data_dir = "data"
    if not os.path.exists(data_dir):
        os.makedirs(data_dir)
    
    # Initialisation de la base de données
    db_path = os.path.join(data_dir, "child_security_complete.db")
    db_helper = DatabaseHelper(db_path)
    
    try:
        # Création des tables
        db_helper.create_tables()
        
        print(f"✅ Base de données créée avec succès: {db_path}")
        print("📊 Tables créées:")
        print("  - users (utilisateurs/parents)")
        print("  - parent_connections (connexions entre parents)")
        print("  - conversations (conversations)")
        print("  - conversation_participants (participants)")
        print("  - messages (messages)")
        print("  - message_reactions (réactions)")
        print("  - community_alerts (alertes communautaires)")
        print("  - alert_comments (commentaires d'alertes)")
        print("  - help_requests (demandes d'aide)")
        print("  - help_responses (réponses d'aide)")
        print("  - education_categories (catégories éducatives)")
        print("  - educational_content (contenu éducatif)")
        print("  - quiz_questions (questions de quiz)")
        print("  - user_progress (progression utilisateur)")
        print("  - parenting_advice (conseils parentaux)")
        print("  - advice_comments (commentaires de conseils)")
        print("  - user_interactions (interactions utilisateur)")
        print("  - ratings (évaluations)")
        print("  - notifications (notifications)")
        print("  - reports (signalements)")
        
    except Exception as e:
        print(f"❌ Erreur lors de la création: {e}")
    finally:
        db_helper.close()

if __name__ == "__main__":
    main()
