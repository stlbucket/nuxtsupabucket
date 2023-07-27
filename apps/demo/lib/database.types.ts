export type Json =
  | string
  | number
  | boolean
  | null
  | { [key: string]: Json | undefined }
  | Json[]

export interface Database {
  app: {
    Tables: {
      app_tenant: {
        Row: {
          created_at: string
          id: string
          identifier: string | null
          name: string
          status: Database["app"]["Enums"]["app_tenant_status"]
          type: Database["app"]["Enums"]["app_tenant_type"]
          updated_at: string
        }
        Insert: {
          created_at?: string
          id?: string
          identifier?: string | null
          name: string
          status?: Database["app"]["Enums"]["app_tenant_status"]
          type?: Database["app"]["Enums"]["app_tenant_type"]
          updated_at?: string
        }
        Update: {
          created_at?: string
          id?: string
          identifier?: string | null
          name?: string
          status?: Database["app"]["Enums"]["app_tenant_status"]
          type?: Database["app"]["Enums"]["app_tenant_type"]
          updated_at?: string
        }
        Relationships: []
      }
      app_tenant_subscription: {
        Row: {
          app_tenant_id: string
          created_at: string
          id: string
          license_pack_key: string
          updated_at: string
        }
        Insert: {
          app_tenant_id: string
          created_at?: string
          id?: string
          license_pack_key: string
          updated_at?: string
        }
        Update: {
          app_tenant_id?: string
          created_at?: string
          id?: string
          license_pack_key?: string
          updated_at?: string
        }
        Relationships: [
          {
            foreignKeyName: "app_tenant_subscription_app_tenant_id_fkey"
            columns: ["app_tenant_id"]
            referencedRelation: "app_tenant"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "app_tenant_subscription_license_pack_key_fkey"
            columns: ["license_pack_key"]
            referencedRelation: "license_pack"
            referencedColumns: ["key"]
          }
        ]
      }
      app_user: {
        Row: {
          avatar_key: string | null
          created_at: string
          display_name: string | null
          email: string
          first_name: string | null
          full_name: string | null
          id: string
          identifier: string | null
          is_public: boolean
          last_name: string | null
          phone: string | null
          status: Database["app"]["Enums"]["app_user_status"]
          updated_at: string
        }
        Insert: {
          avatar_key?: string | null
          created_at?: string
          display_name?: string | null
          email: string
          first_name?: string | null
          full_name?: string | null
          id: string
          identifier?: string | null
          is_public?: boolean
          last_name?: string | null
          phone?: string | null
          status?: Database["app"]["Enums"]["app_user_status"]
          updated_at?: string
        }
        Update: {
          avatar_key?: string | null
          created_at?: string
          display_name?: string | null
          email?: string
          first_name?: string | null
          full_name?: string | null
          id?: string
          identifier?: string | null
          is_public?: boolean
          last_name?: string | null
          phone?: string | null
          status?: Database["app"]["Enums"]["app_user_status"]
          updated_at?: string
        }
        Relationships: [
          {
            foreignKeyName: "app_user_id_fkey"
            columns: ["id"]
            referencedRelation: "users"
            referencedColumns: ["id"]
          }
        ]
      }
      app_user_tenancy: {
        Row: {
          app_tenant_id: string
          app_tenant_name: string
          app_user_id: string | null
          created_at: string
          display_name: string | null
          email: string
          id: string
          invited_by_app_user_id: string | null
          invited_by_display_name: string | null
          status: Database["app"]["Enums"]["app_user_tenancy_status"]
          updated_at: string
        }
        Insert: {
          app_tenant_id: string
          app_tenant_name: string
          app_user_id?: string | null
          created_at?: string
          display_name?: string | null
          email: string
          id?: string
          invited_by_app_user_id?: string | null
          invited_by_display_name?: string | null
          status?: Database["app"]["Enums"]["app_user_tenancy_status"]
          updated_at?: string
        }
        Update: {
          app_tenant_id?: string
          app_tenant_name?: string
          app_user_id?: string | null
          created_at?: string
          display_name?: string | null
          email?: string
          id?: string
          invited_by_app_user_id?: string | null
          invited_by_display_name?: string | null
          status?: Database["app"]["Enums"]["app_user_tenancy_status"]
          updated_at?: string
        }
        Relationships: [
          {
            foreignKeyName: "app_user_tenancy_app_tenant_id_fkey"
            columns: ["app_tenant_id"]
            referencedRelation: "app_tenant"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "app_user_tenancy_app_user_id_fkey"
            columns: ["app_user_id"]
            referencedRelation: "app_user"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "app_user_tenancy_invited_by_app_user_id_fkey"
            columns: ["invited_by_app_user_id"]
            referencedRelation: "app_user"
            referencedColumns: ["id"]
          }
        ]
      }
      application: {
        Row: {
          key: string
          name: string
        }
        Insert: {
          key: string
          name: string
        }
        Update: {
          key?: string
          name?: string
        }
        Relationships: []
      }
      license: {
        Row: {
          app_tenant_id: string
          app_tenant_subscription_id: string
          app_user_tenancy_id: string
          created_at: string
          expires_at: string | null
          id: string
          license_type_key: string
          status: Database["app"]["Enums"]["license_status"]
          updated_at: string
        }
        Insert: {
          app_tenant_id: string
          app_tenant_subscription_id: string
          app_user_tenancy_id: string
          created_at?: string
          expires_at?: string | null
          id?: string
          license_type_key: string
          status?: Database["app"]["Enums"]["license_status"]
          updated_at?: string
        }
        Update: {
          app_tenant_id?: string
          app_tenant_subscription_id?: string
          app_user_tenancy_id?: string
          created_at?: string
          expires_at?: string | null
          id?: string
          license_type_key?: string
          status?: Database["app"]["Enums"]["license_status"]
          updated_at?: string
        }
        Relationships: [
          {
            foreignKeyName: "license_app_tenant_id_fkey"
            columns: ["app_tenant_id"]
            referencedRelation: "app_tenant"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "license_app_tenant_subscription_id_fkey"
            columns: ["app_tenant_subscription_id"]
            referencedRelation: "app_tenant_subscription"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "license_app_user_tenancy_id_fkey"
            columns: ["app_user_tenancy_id"]
            referencedRelation: "app_user_tenancy"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "license_license_type_key_fkey"
            columns: ["license_type_key"]
            referencedRelation: "license_type"
            referencedColumns: ["key"]
          }
        ]
      }
      license_pack: {
        Row: {
          created_at: string
          display_name: string
          key: string
          updated_at: string
        }
        Insert: {
          created_at?: string
          display_name: string
          key: string
          updated_at?: string
        }
        Update: {
          created_at?: string
          display_name?: string
          key?: string
          updated_at?: string
        }
        Relationships: []
      }
      license_pack_license_type: {
        Row: {
          expiration_interval_multiplier: number
          expiration_interval_type: Database["app"]["Enums"]["expiration_interval_type"]
          license_pack_key: string
          license_type_key: string
          number_of_licenses: number
        }
        Insert: {
          expiration_interval_multiplier?: number
          expiration_interval_type?: Database["app"]["Enums"]["expiration_interval_type"]
          license_pack_key: string
          license_type_key: string
          number_of_licenses?: number
        }
        Update: {
          expiration_interval_multiplier?: number
          expiration_interval_type?: Database["app"]["Enums"]["expiration_interval_type"]
          license_pack_key?: string
          license_type_key?: string
          number_of_licenses?: number
        }
        Relationships: [
          {
            foreignKeyName: "license_pack_license_type_license_pack_key_fkey"
            columns: ["license_pack_key"]
            referencedRelation: "license_pack"
            referencedColumns: ["key"]
          },
          {
            foreignKeyName: "license_pack_license_type_license_type_key_fkey"
            columns: ["license_type_key"]
            referencedRelation: "license_type"
            referencedColumns: ["key"]
          }
        ]
      }
      license_type: {
        Row: {
          application_key: string
          created_at: string
          display_name: string
          key: string
          permission_level: Database["app"]["Enums"]["license_type_permission_level"]
          updated_at: string
        }
        Insert: {
          application_key: string
          created_at?: string
          display_name: string
          key: string
          permission_level?: Database["app"]["Enums"]["license_type_permission_level"]
          updated_at?: string
        }
        Update: {
          application_key?: string
          created_at?: string
          display_name?: string
          key?: string
          permission_level?: Database["app"]["Enums"]["license_type_permission_level"]
          updated_at?: string
        }
        Relationships: [
          {
            foreignKeyName: "license_type_application_key_fkey"
            columns: ["application_key"]
            referencedRelation: "application"
            referencedColumns: ["key"]
          }
        ]
      }
      license_type_permission: {
        Row: {
          license_type_key: string
          permission_key: string
        }
        Insert: {
          license_type_key: string
          permission_key: string
        }
        Update: {
          license_type_key?: string
          permission_key?: string
        }
        Relationships: [
          {
            foreignKeyName: "license_type_permission_license_type_key_fkey"
            columns: ["license_type_key"]
            referencedRelation: "license_type"
            referencedColumns: ["key"]
          },
          {
            foreignKeyName: "license_type_permission_permission_key_fkey"
            columns: ["permission_key"]
            referencedRelation: "permission"
            referencedColumns: ["key"]
          }
        ]
      }
      permission: {
        Row: {
          key: string
        }
        Insert: {
          key: string
        }
        Update: {
          key?: string
        }
        Relationships: []
      }
    }
    Views: {
      [_ in never]: never
    }
    Functions: {
      application_license_count: {
        Args: {
          _application: unknown
        }
        Returns: number
      }
      license_pack_license_type_issued_count: {
        Args: {
          _license_pack_license_type: unknown
        }
        Returns: number
      }
    }
    Enums: {
      app_tenant_status: "active" | "inactive" | "paused"
      app_tenant_type: "anchor" | "customer" | "demo" | "test" | "trial"
      app_user_status: "active" | "inactive" | "blocked"
      app_user_tenancy_status:
        | "invited"
        | "declined"
        | "active"
        | "inactive"
        | "blocked"
        | "supporting"
      expiration_interval_type:
        | "none"
        | "day"
        | "week"
        | "month"
        | "quarter"
        | "year"
        | "explicit"
      license_status: "active" | "inactive" | "expired"
      license_type_permission_level: "user" | "admin" | "superadmin" | "none"
    }
    CompositeTypes: {
      [_ in never]: never
    }
  }
  app_fn: {
    Tables: {
      [_ in never]: never
    }
    Views: {
      [_ in never]: never
    }
    Functions: {
      app_tenant_app_user_tenancies: {
        Args: {
          _app_tenant_id: string
        }
        Returns: {
          app_tenant_id: string
          app_tenant_name: string
          app_user_id: string | null
          created_at: string
          display_name: string | null
          email: string
          id: string
          invited_by_app_user_id: string | null
          invited_by_display_name: string | null
          status: Database["app"]["Enums"]["app_user_tenancy_status"]
          updated_at: string
        }[]
      }
      app_tenant_licenses: {
        Args: {
          _app_tenant_id: string
        }
        Returns: {
          app_tenant_id: string
          app_tenant_subscription_id: string
          app_user_tenancy_id: string
          created_at: string
          expires_at: string | null
          id: string
          license_type_key: string
          status: Database["app"]["Enums"]["license_status"]
          updated_at: string
        }[]
      }
      assume_app_user_tenancy: {
        Args: {
          _app_user_tenancy_id: string
          _email: string
        }
        Returns: {
          app_tenant_id: string
          app_tenant_name: string
          app_user_id: string | null
          created_at: string
          display_name: string | null
          email: string
          id: string
          invited_by_app_user_id: string | null
          invited_by_display_name: string | null
          status: Database["app"]["Enums"]["app_user_tenancy_status"]
          updated_at: string
        }
      }
      become_support: {
        Args: {
          _app_tenant_id: string
          _app_user_id: string
        }
        Returns: {
          app_tenant_id: string
          app_tenant_name: string
          app_user_id: string | null
          created_at: string
          display_name: string | null
          email: string
          id: string
          invited_by_app_user_id: string | null
          invited_by_display_name: string | null
          status: Database["app"]["Enums"]["app_user_tenancy_status"]
          updated_at: string
        }
      }
      configure_user_metadata: {
        Args: {
          _app_user_id: string
        }
        Returns: undefined
      }
      create_anchor_tenant: {
        Args: {
          _name: string
          _email?: string
        }
        Returns: {
          created_at: string
          id: string
          identifier: string | null
          name: string
          status: Database["app"]["Enums"]["app_tenant_status"]
          type: Database["app"]["Enums"]["app_tenant_type"]
          updated_at: string
        }
      }
      create_app_tenant: {
        Args: {
          _name: string
          _identifier?: string
          _email?: string
          _type?: Database["app"]["Enums"]["app_tenant_type"]
        }
        Returns: {
          created_at: string
          id: string
          identifier: string | null
          name: string
          status: Database["app"]["Enums"]["app_tenant_status"]
          type: Database["app"]["Enums"]["app_tenant_type"]
          updated_at: string
        }
      }
      current_app_user_claims: {
        Args: {
          _app_user_id: string
        }
        Returns: Database["app_fn"]["CompositeTypes"]["app_user_claims"]
      }
      decline_invitation: {
        Args: {
          _app_user_tenancy_id: string
        }
        Returns: {
          app_tenant_id: string
          app_tenant_name: string
          app_user_id: string | null
          created_at: string
          display_name: string | null
          email: string
          id: string
          invited_by_app_user_id: string | null
          invited_by_display_name: string | null
          status: Database["app"]["Enums"]["app_user_tenancy_status"]
          updated_at: string
        }
      }
      demo_app_user_tenancies: {
        Args: Record<PropertyKey, never>
        Returns: {
          app_tenant_id: string
          app_tenant_name: string
          app_user_id: string | null
          created_at: string
          display_name: string | null
          email: string
          id: string
          invited_by_app_user_id: string | null
          invited_by_display_name: string | null
          status: Database["app"]["Enums"]["app_user_tenancy_status"]
          updated_at: string
        }[]
      }
      get_ab_listings: {
        Args: {
          _app_user_id: string
          _user_app_tenant_id: string
        }
        Returns: Database["app_fn"]["CompositeTypes"]["ab_listing"][]
      }
      install_anchor_application: {
        Args: Record<PropertyKey, never>
        Returns: {
          key: string
          name: string
        }
      }
      install_application: {
        Args: {
          _application_info: Database["app_fn"]["CompositeTypes"]["application_info"]
        }
        Returns: {
          key: string
          name: string
        }
      }
      invite_user: {
        Args: {
          _app_tenant_id: string
          _email: string
          _permission_level?: Database["app"]["Enums"]["license_type_permission_level"]
        }
        Returns: {
          app_tenant_id: string
          app_tenant_name: string
          app_user_id: string | null
          created_at: string
          display_name: string | null
          email: string
          id: string
          invited_by_app_user_id: string | null
          invited_by_display_name: string | null
          status: Database["app"]["Enums"]["app_user_tenancy_status"]
          updated_at: string
        }
      }
      join_address_book: {
        Args: {
          _app_user_id: string
        }
        Returns: {
          avatar_key: string | null
          created_at: string
          display_name: string | null
          email: string
          first_name: string | null
          full_name: string | null
          id: string
          identifier: string | null
          is_public: boolean
          last_name: string | null
          phone: string | null
          status: Database["app"]["Enums"]["app_user_status"]
          updated_at: string
        }
      }
      leave_address_book: {
        Args: {
          _app_user_id: string
        }
        Returns: {
          avatar_key: string | null
          created_at: string
          display_name: string | null
          email: string
          first_name: string | null
          full_name: string | null
          id: string
          identifier: string | null
          is_public: boolean
          last_name: string | null
          phone: string | null
          status: Database["app"]["Enums"]["app_user_status"]
          updated_at: string
        }
      }
      my_app_user_tenancies: {
        Args: {
          _email: string
        }
        Returns: {
          app_tenant_id: string
          app_tenant_name: string
          app_user_id: string | null
          created_at: string
          display_name: string | null
          email: string
          id: string
          invited_by_app_user_id: string | null
          invited_by_display_name: string | null
          status: Database["app"]["Enums"]["app_user_tenancy_status"]
          updated_at: string
        }[]
      }
      subscribe_tenant_to_license_pack: {
        Args: {
          _app_tenant_id: string
          _license_pack_key: string
        }
        Returns: {
          app_tenant_id: string
          created_at: string
          id: string
          license_pack_key: string
          updated_at: string
        }
      }
      update_profile: {
        Args: {
          _app_user_id: string
          _display_name: string
          _first_name: string
          _last_name: string
          _phone?: string
        }
        Returns: {
          avatar_key: string | null
          created_at: string
          display_name: string | null
          email: string
          first_name: string | null
          full_name: string | null
          id: string
          identifier: string | null
          is_public: boolean
          last_name: string | null
          phone: string | null
          status: Database["app"]["Enums"]["app_user_status"]
          updated_at: string
        }
      }
    }
    Enums: {
      [_ in never]: never
    }
    CompositeTypes: {
      ab_listing: {
        app_user_id: string
        email: string
        phone: string
        full_name: string
        display_name: string
        can_invite: boolean
      }
      app_user_claims: {
        app_user_id: string
        app_tenant_id: string
        app_user_tenancy_id: string
        app_user_status: Database["app"]["Enums"]["app_user_status"]
        permissions: unknown
        email: string
        display_name: string
        app_tenant_name: string
      }
      application_info: {
        key: string
        name: string
        license_type_infos: unknown
        license_pack_infos: unknown
      }
      license_pack_info: {
        key: string
        display_name: string
        license_pack_license_type_infos: unknown
      }
      license_pack_license_type_info: {
        license_type_key: string
        number_of_licenses: number
        expiration_interval_type: Database["app"]["Enums"]["expiration_interval_type"]
        expiration_interval_multiplier: number
      }
      license_type_info: {
        key: string
        display_name: string
        permission_level: Database["app"]["Enums"]["license_type_permission_level"]
        permissions: unknown
      }
      paging_options: {
        item_offset: number
        page_offset: number
        item_limit: number
      }
    }
  }
  graphql_public: {
    Tables: {
      [_ in never]: never
    }
    Views: {
      [_ in never]: never
    }
    Functions: {
      graphql: {
        Args: {
          operationName?: string
          query?: string
          variables?: Json
          extensions?: Json
        }
        Returns: Json
      }
    }
    Enums: {
      [_ in never]: never
    }
    CompositeTypes: {
      [_ in never]: never
    }
  }
  public: {
    Tables: {
      [_ in never]: never
    }
    Views: {
      [_ in never]: never
    }
    Functions: {
      citext:
        | {
            Args: {
              "": string
            }
            Returns: string
          }
        | {
            Args: {
              "": boolean
            }
            Returns: string
          }
        | {
            Args: {
              "": unknown
            }
            Returns: string
          }
      citext_hash: {
        Args: {
          "": string
        }
        Returns: number
      }
      citextin: {
        Args: {
          "": unknown
        }
        Returns: string
      }
      citextout: {
        Args: {
          "": string
        }
        Returns: unknown
      }
      citextrecv: {
        Args: {
          "": unknown
        }
        Returns: string
      }
      citextsend: {
        Args: {
          "": string
        }
        Returns: string
      }
    }
    Enums: {
      [_ in never]: never
    }
    CompositeTypes: {
      [_ in never]: never
    }
  }
  storage: {
    Tables: {
      buckets: {
        Row: {
          allowed_mime_types: string[] | null
          avif_autodetection: boolean | null
          created_at: string | null
          file_size_limit: number | null
          id: string
          name: string
          owner: string | null
          public: boolean | null
          updated_at: string | null
        }
        Insert: {
          allowed_mime_types?: string[] | null
          avif_autodetection?: boolean | null
          created_at?: string | null
          file_size_limit?: number | null
          id: string
          name: string
          owner?: string | null
          public?: boolean | null
          updated_at?: string | null
        }
        Update: {
          allowed_mime_types?: string[] | null
          avif_autodetection?: boolean | null
          created_at?: string | null
          file_size_limit?: number | null
          id?: string
          name?: string
          owner?: string | null
          public?: boolean | null
          updated_at?: string | null
        }
        Relationships: [
          {
            foreignKeyName: "buckets_owner_fkey"
            columns: ["owner"]
            referencedRelation: "users"
            referencedColumns: ["id"]
          }
        ]
      }
      migrations: {
        Row: {
          executed_at: string | null
          hash: string
          id: number
          name: string
        }
        Insert: {
          executed_at?: string | null
          hash: string
          id: number
          name: string
        }
        Update: {
          executed_at?: string | null
          hash?: string
          id?: number
          name?: string
        }
        Relationships: []
      }
      objects: {
        Row: {
          bucket_id: string | null
          created_at: string | null
          id: string
          last_accessed_at: string | null
          metadata: Json | null
          name: string | null
          owner: string | null
          path_tokens: string[] | null
          updated_at: string | null
          version: string | null
        }
        Insert: {
          bucket_id?: string | null
          created_at?: string | null
          id?: string
          last_accessed_at?: string | null
          metadata?: Json | null
          name?: string | null
          owner?: string | null
          path_tokens?: string[] | null
          updated_at?: string | null
          version?: string | null
        }
        Update: {
          bucket_id?: string | null
          created_at?: string | null
          id?: string
          last_accessed_at?: string | null
          metadata?: Json | null
          name?: string | null
          owner?: string | null
          path_tokens?: string[] | null
          updated_at?: string | null
          version?: string | null
        }
        Relationships: [
          {
            foreignKeyName: "objects_bucketId_fkey"
            columns: ["bucket_id"]
            referencedRelation: "buckets"
            referencedColumns: ["id"]
          }
        ]
      }
    }
    Views: {
      [_ in never]: never
    }
    Functions: {
      can_insert_object: {
        Args: {
          bucketid: string
          name: string
          owner: string
          metadata: Json
        }
        Returns: undefined
      }
      extension: {
        Args: {
          name: string
        }
        Returns: string
      }
      filename: {
        Args: {
          name: string
        }
        Returns: string
      }
      foldername: {
        Args: {
          name: string
        }
        Returns: unknown
      }
      get_size_by_bucket: {
        Args: Record<PropertyKey, never>
        Returns: {
          size: number
          bucket_id: string
        }[]
      }
      search: {
        Args: {
          prefix: string
          bucketname: string
          limits?: number
          levels?: number
          offsets?: number
          search?: string
          sortcolumn?: string
          sortorder?: string
        }
        Returns: {
          name: string
          id: string
          updated_at: string
          created_at: string
          last_accessed_at: string
          metadata: Json
        }[]
      }
    }
    Enums: {
      [_ in never]: never
    }
    CompositeTypes: {
      [_ in never]: never
    }
  }
  todo: {
    Tables: {
      todo: {
        Row: {
          app_tenant_id: string
          app_user_tenancy_id: string
          created_at: string
          description: string | null
          id: string
          name: string
          ordinal: number
          parent_todo_id: string | null
          pinned: boolean
          project_todo_id: string | null
          status: Database["todo"]["Enums"]["todo_status"]
          type: Database["todo"]["Enums"]["todo_type"]
          updated_at: string
        }
        Insert: {
          app_tenant_id: string
          app_user_tenancy_id: string
          created_at?: string
          description?: string | null
          id?: string
          name: string
          ordinal: number
          parent_todo_id?: string | null
          pinned?: boolean
          project_todo_id?: string | null
          status?: Database["todo"]["Enums"]["todo_status"]
          type?: Database["todo"]["Enums"]["todo_type"]
          updated_at?: string
        }
        Update: {
          app_tenant_id?: string
          app_user_tenancy_id?: string
          created_at?: string
          description?: string | null
          id?: string
          name?: string
          ordinal?: number
          parent_todo_id?: string | null
          pinned?: boolean
          project_todo_id?: string | null
          status?: Database["todo"]["Enums"]["todo_status"]
          type?: Database["todo"]["Enums"]["todo_type"]
          updated_at?: string
        }
        Relationships: [
          {
            foreignKeyName: "todo_app_tenant_id_fkey"
            columns: ["app_tenant_id"]
            referencedRelation: "app_tenant"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "todo_app_user_tenancy_id_fkey"
            columns: ["app_user_tenancy_id"]
            referencedRelation: "app_user_tenancy"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "todo_parent_todo_id_fkey"
            columns: ["parent_todo_id"]
            referencedRelation: "todo"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "todo_project_todo_id_fkey"
            columns: ["project_todo_id"]
            referencedRelation: "todo"
            referencedColumns: ["id"]
          }
        ]
      }
    }
    Views: {
      [_ in never]: never
    }
    Functions: {
      [_ in never]: never
    }
    Enums: {
      todo_status: "incomplete" | "complete" | "archived" | "unfinished"
      todo_type: "task" | "milestone" | "project"
    }
    CompositeTypes: {
      [_ in never]: never
    }
  }
  todo_fn: {
    Tables: {
      [_ in never]: never
    }
    Views: {
      [_ in never]: never
    }
    Functions: {
      assign_todo: {
        Args: {
          _todo_id: string
          _app_user_tenancy_id: string
        }
        Returns: {
          app_tenant_id: string
          app_user_tenancy_id: string
          created_at: string
          description: string | null
          id: string
          name: string
          ordinal: number
          parent_todo_id: string | null
          pinned: boolean
          project_todo_id: string | null
          status: Database["todo"]["Enums"]["todo_status"]
          type: Database["todo"]["Enums"]["todo_type"]
          updated_at: string
        }
      }
      create_todo: {
        Args: {
          _app_tenant_id: string
          _app_user_tenancy_id: string
          _name: string
          _description?: string
          _parent_todo_id?: string
        }
        Returns: {
          app_tenant_id: string
          app_user_tenancy_id: string
          created_at: string
          description: string | null
          id: string
          name: string
          ordinal: number
          parent_todo_id: string | null
          pinned: boolean
          project_todo_id: string | null
          status: Database["todo"]["Enums"]["todo_status"]
          type: Database["todo"]["Enums"]["todo_type"]
          updated_at: string
        }
      }
      delete_todo: {
        Args: {
          _todo_id: string
        }
        Returns: boolean
      }
      pin_todo: {
        Args: {
          _todo_id: string
        }
        Returns: {
          app_tenant_id: string
          app_user_tenancy_id: string
          created_at: string
          description: string | null
          id: string
          name: string
          ordinal: number
          parent_todo_id: string | null
          pinned: boolean
          project_todo_id: string | null
          status: Database["todo"]["Enums"]["todo_status"]
          type: Database["todo"]["Enums"]["todo_type"]
          updated_at: string
        }
      }
      search_todos: {
        Args: {
          _options: Database["todo_fn"]["CompositeTypes"]["search_todos_options"]
        }
        Returns: {
          app_tenant_id: string
          app_user_tenancy_id: string
          created_at: string
          description: string | null
          id: string
          name: string
          ordinal: number
          parent_todo_id: string | null
          pinned: boolean
          project_todo_id: string | null
          status: Database["todo"]["Enums"]["todo_status"]
          type: Database["todo"]["Enums"]["todo_type"]
          updated_at: string
        }[]
      }
      unpin_todo: {
        Args: {
          _todo_id: string
        }
        Returns: {
          app_tenant_id: string
          app_user_tenancy_id: string
          created_at: string
          description: string | null
          id: string
          name: string
          ordinal: number
          parent_todo_id: string | null
          pinned: boolean
          project_todo_id: string | null
          status: Database["todo"]["Enums"]["todo_status"]
          type: Database["todo"]["Enums"]["todo_type"]
          updated_at: string
        }
      }
      update_todo: {
        Args: {
          _todo_id: string
          _name: string
          _description?: string
        }
        Returns: {
          app_tenant_id: string
          app_user_tenancy_id: string
          created_at: string
          description: string | null
          id: string
          name: string
          ordinal: number
          parent_todo_id: string | null
          pinned: boolean
          project_todo_id: string | null
          status: Database["todo"]["Enums"]["todo_status"]
          type: Database["todo"]["Enums"]["todo_type"]
          updated_at: string
        }
      }
      update_todo_status: {
        Args: {
          _todo_id: string
          _status: Database["todo"]["Enums"]["todo_status"]
        }
        Returns: {
          app_tenant_id: string
          app_user_tenancy_id: string
          created_at: string
          description: string | null
          id: string
          name: string
          ordinal: number
          parent_todo_id: string | null
          pinned: boolean
          project_todo_id: string | null
          status: Database["todo"]["Enums"]["todo_status"]
          type: Database["todo"]["Enums"]["todo_type"]
          updated_at: string
        }
      }
    }
    Enums: {
      [_ in never]: never
    }
    CompositeTypes: {
      search_todos_options: {
        search_term: string
        todo_type: Database["todo"]["Enums"]["todo_type"]
        todo_status: Database["todo"]["Enums"]["todo_status"]
        roots_only: boolean
        paging_options: Database["app_fn"]["CompositeTypes"]["paging_options"]
      }
    }
  }
}

