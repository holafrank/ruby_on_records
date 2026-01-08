# frozen_string_literal: true

class Ability
  include CanCan::Ability

  def initialize(user)
    # Define abilities for the user here. For example:
    #
    #   return unless user.present?
    #   can :read, :all
    #   return unless user.admin?
    #   can :manage, :all
    #
    # The first argument to `can` is the action you are giving the user
    # permission to do.
    # If you pass :manage it will apply to every action. Other common actions
    # here are :read, :create, :update and :destroy.
    #
    # The second argument is the resource the user can perform the action on.
    # If you pass :all it will apply to every resource. Otherwise pass a Ruby
    # class of the resource.
    #
    # The third argument is an optional hash of conditions to further filter the
    # objects.
    # For example, here the user can only update published articles.
    #
    #   can :update, Article, published: true
    #
    # See the wiki for details:
    # https://github.com/CanCanCommunity/cancancan/blob/develop/docs/define_check_abilities.md


    # Datos públicos
    can :read, Disk
    can :read, Genre

    # El resto de los recursos deben ser accedidos por usuarios logueados únicamente.
    return unless user.present?

    # Todos los roles deben poder modificar los datos de su propia cuenta, menos su rol.

    # Un empleado puede administrar productos y ventas, pero no puede gestionar usuarios.
    # Puede editar sólo sus propios datos.
    if user.employee?
      can [ :create, :new, :read, :update, :edit, :destroy ], Disk
      can [ :create, :new, :read, :update, :edit, :destroy ], Sale
      can [ :create, :new, :read, :update, :edit, :destroy ], Genre

      can [ :show, :update, :edit ], User, [ :full_name, :email, :password_digest ], id: user.id
      cannot [ :update ], User, [ :role ], id: user.id
      cannot :index, User

    end

    # Un gerente puede administrar productos y ventas, y gestionar usuarios,
    # pero no puede crear ni modificar usuarios con rol de administrador.
    if user.manager?
      can [ :create, :new, :read, :update, :edit, :destroy ], Disk
      can [ :create, :new, :read, :update, :edit, :destroy ], Sale
      can [ :create, :new, :read, :update, :edit, :destroy ], Genre

      can :read, User

      can [ :create, :new, :update, :edit, :destroy ], User, role: [:employee, :manager]
      cannot [ :update ], User, [ :role ], id: user.id

    end

    # El administrador tiene todos los permisos. Tiene acceso a todas las funcionalidades de la aplicación.
    # Puede incluso crear/editar/eliminar otros usuarios administradores.
    if user.admin?
      can :manage, :all
      cannot [ :update ], User, [ :role ], id: user.id
    end
  end
end
