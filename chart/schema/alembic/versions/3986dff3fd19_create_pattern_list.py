"""create pattern list

Revision ID: 3986dff3fd19
Revises: 
Create Date: 2015-07-14 11:28:19.752000

"""

# revision identifiers, used by Alembic.
revision = '3986dff3fd19'
down_revision = None
branch_labels = None
depends_on = None

from alembic import op
import sqlalchemy as sa


def upgrade():
    op.create_table(
        'patternMaster',
        sa.Column('id', sa.Integer, primary_key=True),
        sa.Column('name', sa.String(50), nullable=False),
        sa.Column('description', sa.Unicode(200))
    )


def downgrade():
    op.drop_table('patternMaster')
